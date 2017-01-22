use v6;

#| management class for a set of CSS::Declarations
class CSS::Declarations {

    use CSS::Declarations::Property;
    use CSS::Declarations::Edges;
    use CSS::Declarations::Units;
    use CSS::Module;
    use CSS::Module::CSS3;
    use CSS::Writer;
    use Color;
    my %module-metadata{CSS::Module};     # per-module metadata
    my %module-properties{CSS::Module};   # per-module property attributes

    # contextual variables
    has Any %!values;         # property values
    has Array %!box;
    has Hash %!struct;
    has Bool %!important;
    my subset Handling of Str where 'initial'|'inherit';
    has Handling %!handling;
    has %!default;
    has CSS::Module $.module = CSS::Module::CSS3.module; #| associated CSS module
    has @.warnings;
    has Bool $.warn = True;

    multi sub make-property(CSS::Module $m, Str $name where { %module-properties{$m}{$name}:exists })  {
        %module-properties{$m}{$name}
    }

    multi sub make-property(CSS::Module $m, Str $name) is default {
        with %module-metadata{$m}{$name} -> %defs {
            with %defs<edges> {
                # e.g. margin, comprised of margin-top, margin-right, margin-bottom, margin-left
                for .list -> $side {
                    # these shouldn't nest or cycle
                    %defs{$side} = $_ with make-property($m, $side);
                }
                %module-properties{$m}{$name} = CSS::Declarations::Edges.new( :$name, |%defs);
            }
            else {
                %module-properties{$m}{$name} = CSS::Declarations::Property.new( :$name, |%defs );
            }
        }
        else {
            die "unknown property: $name"
        }
        %module-properties{$m}{$name};
    }

    #| return module meta-data for a property
    method info(Str $prop) {
        with %module-properties{$!module}{$prop} {
            $_;
        }
        else {
            make-property($!module, $prop);
        }
    }

    method !get-props(Str $prop-name, List $expr) {
        my @props;

        my @expr;
        for $expr.list {
            if $_ ~~ Pair|Hash && .keys[0] ~~ /^'expr:'(.*)$/ {
                # embedded property declaration
                @props.push: ~$0 => .values[0]
            }
            else {
                # filter out '/' operator, as in 'font:10pt/12pt times-roman'
                @expr.push: $_
                    unless $prop-name eq 'font' && .<op> eqv '/';
            }
        }

        @props.push: $prop-name => @expr
            if @expr;

        @props;
    }

    method !build-property($prop, $expr, :$important) {
        my \keyw = $expr[0]<keyw>;
        if keyw ~~ Handling {
            self.handling($prop) = keyw;
        }
        else {
            self."$prop"() = $expr;
            self.important($prop) = $_
                with $important;
        }
    }

    method !build-style(Str $style) {
        my $rule = "declaration-list";
        my $actions = $!module.actions.new;
        $!module.grammar.parse($style, :$rule, :$actions)
            or die "unable to parse CSS style declarations: $style";
        @!warnings = $actions.warnings;
        if $!warn {
            note .message for @!warnings;
        }
        my @declarations = $/.ast.list;

        for @declarations {
            my \decl = .value;
            given .key {
                when 'property' {
                    with decl<expr> -> \expr {
                        my $important = True
                            if decl<prio> ~~ 'important';

                        self!build-property( .key, .value, :$important)
                            for self!get-props(decl<ident>, expr).list;
                    }
                }
                default {
                    die "ignoring: $_ declaration";
                }
            }
        }
    }

    submethod TWEAK( Str :$style, :$inherit = [], :$copy, :$module, :$tweak, :$warn, *%props, ) {
        %module-metadata{$!module} //= do with $!module.property-metadata {
            $_
        }
        else {
            die "module {$!module.name} lacks meta-data"
        };

        self!build-style($_) with $style;
        self.inherit($_) for $inherit.list;
        self!copy($_) with $copy;
        self.set-properties(|%props);
    }

    method !box-value(Str $prop, List $edges) is rw {
	Proxy.new(
	    FETCH => sub ($) {
                %!box{$prop} //= do {
                    my $n = 0;
                    my @bound;
                    @bound[$n++] := self!item-value($_)
                        for $edges.list;
                    @bound;
                }
            },
	    STORE => sub ($,$v) {
		# expand and assign values to child properties
		my @v = $v.isa(List) ?? $v.list !! [$v];
		@v[1] //= @v[0];
		@v[2] //= @v[0];
		@v[3] //= @v[1];

		my $n = 0;
                for $edges.list -> $prop {
		    %!values{$prop} = $_
                        with self!coerce( @v[$n++], :$prop )
                }
	    }
        );
    }

    method !struct-value(Str $prop, List $children) is rw {
	Proxy.new(
	    FETCH => sub ($) {
                %!struct{$prop} //= do {
                    my $n = 0;
                    my %bound;
                    %bound{$_} := self."$_"()
                        for $children.list;
                    %bound;
                }
            },
	    STORE => sub ($, $rval) {
                my %vals;
                if $rval ~~ Associative {
                    %vals = %$rval;
                }
                else {
                    with self.module.parse-property($prop, $rval, :$!warn) {
                        my @props = self!get-props($prop, $_);
                        %vals{.key} = .value for @props;
                    }
                }

                for $children.list -> $prop {
                    with %vals{$prop}:delete {
                        self."$prop"() = $_
                            with self!coerce($_, :$prop);
                    }
                    else {
                        self.delete($prop);
                    }
	        }
                note "unknown child properties of $prop: {%vals.keys}"
                    if %vals
            }
            );
    }

    method !metadata { %module-metadata{$!module} }
    #| return the default value for the property
    method !default($prop) {
        %!default{$prop} //= self!coerce( .<default>[1] )
            with self!metadata{$prop};
    }

    method !item-value(Str $prop) {
        Proxy.new(
            FETCH => sub ($) {
                if %!values{$prop}:exists {
                    %!values{$prop};
                }
                elsif $prop ~~ /^'border-'[top|right|bottom|left]'-color'$/ {
                    self.?color;
                }
                elsif $prop eq 'text-align' {
                    self.can('direction') && self.direction eq 'rtl' ?? 'right' !! 'left';
                }
                else {
                    %!values{$prop} = self!default($prop)
                }
            },
            STORE => sub ($,$v) {
                %!values{$prop} = $_
                    with self!coerce( $v, :$prop )
            }
        );
    }

    method !child-handling(List $children) is rw {
        Proxy.new(
            FETCH => sub ($) { [&&] $children.map: { %!handling{$_} } },
            STORE => sub ($,Str $h) {
                %!handling{$_} = $h
                    for $children.list;
            });
    }

    #| return property value handling: 'initial', or 'inherit';
    method handling(Str $prop --> Handling) is rw {
        with self.info($prop) {
            .edges
                ?? self!child-handling( .edges )
                !! %!handling{$prop}
        }
    }

    method !child-importance(List $children) is rw {
        Proxy.new(
            FETCH => sub ($) { [&&] $children.map: { %!important{$_} } },
            STORE => sub ($,Bool $v) {
                %!important{$_} = $v
                    for $children.list;
            });
    }

    #| return true of the property has the !important attribute
    method important(Str $prop) is rw {
        with self.info($prop) {
            .edges
                ?? self!child-importance( .edges )
                !! %!important{$prop}
        }
    }

    my subset ColorAST of Pair where {.key eq 'rgb'|'rgba'|'hsl'|'hsla'}

    multi method from-ast(ColorAST $v) {
        my @channels = $v.value.map: {self.from-ast: $_};
        my Color $color;
        my $type = $v.key;
        @channels[*-1] *= 256
            if $type eq 'rgba'|'hsla';
        if $type eq 'hsla' {
            my Numeric \a = @channels.pop;
            my %rgba = hsl2rgb(@channels);
            %rgba<a> = a;
            $color .= new: |%rgba;
        }
        else {
            $color .= new: |($type => @channels);
        }

        $color does CSS::Declarations::Units::Type[$type];
    }
    multi method from-ast(Pair $v is copy where .key eq 'keyw') {
        if $v.value eq 'transparent' {
            $v = 'rgba' => Color.new: :r(0), :g(0), :b(0), :a(0)
        }
        $v.value but CSS::Declarations::Units::Type[$v.key]
    }
    method !set-type(\v, \type) {
        v ~~ Color|Hash|Array
            ?? v does CSS::Declarations::Units::Type[type]
            !! v but  CSS::Declarations::Units::Type[type];
    }
    multi method from-ast(Pair $v) {
        my \r = self.from-ast( $v.value );
        r ~~ CSS::Declarations::Units::Type
            ?? r
            !! self!set-type(r, $v.key);
    }
    multi method from-ast(List $v) {
        $v.elems == 1
            ?? self.from-ast( $v[0] )
            !! [ $v.map: { self.from-ast($_) } ];
    }
    #| { :int(42) } => :int(42)
    multi method from-ast(Hash $v where .keys == 1) {
        self.from-ast( $v.pairs[0] );
    }
    multi method from-ast($v) is default {
        $v
    }

    multi sub coerce-str(List $_) {
        .map({ coerce-str($_) // return }).join: ' ';
    }
    multi sub coerce-str($_) is default {
        .Str if $_ ~~ Str|Numeric && ! .can('type');
    }
    has %!prop-cache; # cache, for performance
    method !coerce($val, Str :$prop) {
        my \expr = do with $prop && coerce-str($val) {
            (%!prop-cache{$prop}{$_} //= $.module.parse-property($prop, $_, :$!warn))
        }
        else {
            $val
        }
        self.from-ast(expr);
    }

    #| convert 0 .. 255  =>  0.0 .. 1.0. round to 2 decimal places
    sub alpha($a) {
        :num(($a * 100/256).round / 100);
    }

    multi method to-ast(Pair $v) { $v }

    multi method to-ast($v, :$get = True) is default {
        my $key = $v.?type if $get;

        my $val = do given $v {
            when Color {
                my \type = .type;
                if type eq 'hsl' {
                    my (\h, \s, \l) = .hsl;
                    [ :num(h), :percent(s), :percent(l) ];
                }
                elsif type eq 'hsla' {
                    my (\h, \s, \l) = .hsl;
                    [ :num(h), :percent(s), :percent(l), alpha(.a) ];
                }
                elsif type eq 'rgba' {
                    my (\r, \g, \b, \a) = .rgba;
                    [ :num(r), :num(g), :num(b), alpha(a) ];
                }
                else {
                     [ $v."$key"().map: -> $num { :$num } ]
                }
            }
            when List  {
                .elems == 1
                    ?? self.to-ast( .[0] )
                    !! [ .map: { self.to-ast($_) } ];
            }
            default {
                $key
                    ?? self.to-ast($_, :!get)
                    !! $_;
            }
        }

        $key
            ?? ($key => $val)
            !! $val;
    }

    #| CSS conformant inheritance from the given parent declaration list. Note:
    #| - handling of 'initial' and 'inherit' in the child declarations
    #| - !important override properties in parent
    #| - not all properties are inherited. e.g. color is, margin isn't
    method inherit(CSS::Declarations $css) {
        for $css.properties -> \name {
            my \info = self.info(name);
            unless info.box {
                my $inherit = False;
                my $important = False;
                with self.handling(name) {
                    when 'initial' { %!values{name}:delete }
                    when 'inherit' { $inherit = True }
                }
                elsif $css.important(name) {
                    $inherit = True;
                    $important = True;
                }
                elsif info.inherit {
                    $inherit = True without %!values{name};
                }
                if $inherit {
                    %!values{name} = $css."{name}"();
                    self.important(name) = True
                        if $important;
                }
            }
        }
    }

    method !copy(CSS::Declarations $css) {
        %!values{$_} = $css."$_"()
            for $css.properties;
    }

    #| set a list of properties as hash pairs
    method set-properties(*%props) {
        for %props.pairs -> \p {
            if %module-metadata{$!module}{p.key} {
                self."{p.key}"() = $_ with p.value;
            }
            else {
                warn "unknown property/option: {p.key}";
            }
        }
        self;
    }

    #| create a deep copy of a CSS declarations object
    method clone(*%props) {
        my $obj = self.new( :copy(self), :$!module );
        $obj.set-properties(|%props);
        $obj;
    }

    my subset ZeroNum of Numeric where {$_ =~= 0};
    our proto sub same(\a, \b) {*}
    multi sub same(Associative \a, Associative \b) {
        my \p1 = a.pairs[0];
        my \p2 = b.pairs[0];
        ((p1.value ~~ ZeroNum && p2.value ~~ ZeroNum)
         || p1.perl eq p2.perl) ?? a !! False;
    }
    multi sub same(\a, \b) is default {a eqv b ?? a !! False}

    # Avoid these serialization optimizations, which won't parse correctly:
    #     font: bold;
    #     font: bold Helvetica;
    # Need a font-size to disambiguate, e.g.: 
    #     font: bold medium Helvetica;
    #     font: medium Helvetica;
    multi method optimizable('font', :@children!
                              where <font-size font-family> ⊈ .Set ) {
        False;
    }

    multi method optimizable(Str $, :@children) is default {
        @children >= 2;
    }

    method !optimize-ast( %prop-ast ) {
        my \metadata = self!metadata;
        my @compound-properties = metadata.keys.sort.grep: { metadata{$_}<children> };
        my %edges;

        for %prop-ast.keys -> \prop {
            # delete properties that match the default value
            my \info = self.info(prop);
            with %prop-ast{prop}<expr> {
                my \val = .[0];
                my \default = self.to-ast: self!default(prop);

                %prop-ast{prop}:delete
                    if (val.elems == 1
                        ?? same(val, default[0])
                        !! same(val, default));
            }
            %edges{info.edge}++ if info.edge;
        }

        # consolidate box properties with common values
        # margin-right: 1pt; ... margin-bottom: 1pt -> margin: 1pt
        for %edges.keys -> \prop {
            # bottom up aggregation of edges. e.g. border-top-width, border-right-width ... => border-width
            my \info = self.info(prop);
            next unless info.box;
            my @edges = info.edges;
            my @asts = @edges.map: { %prop-ast{$_} };
            # we just handle the simplest case at the moment. Consolidate,
            # if all four properties are present, and have the same value
            if [[&same]] @asts {
                %prop-ast{$_}:delete for @edges;
                %prop-ast{prop} = @asts[0];
            }
        }
        for @compound-properties -> \prop {
            # top-down aggregation of compound properties. e.g. border-width, border-style => border
            
            my @children = metadata{prop}<children>.list.grep: {
                %prop-ast{$_}:exists
            }

            next unless $.optimizable(prop, :@children);

            # take the simple approach of building the compound property, iff
            # all children are consistant
            # -- if child properties are 'initial', or 'inherit', they all
            #    need to be present and the same
            # -- otherwise they need to all need to have or lack
            #    the !important indicator

            my @child-types = @children.map: {
                given %prop-ast{$_} {
                    when .<keyw> ~~ Handling {.<keyw>}
                    when .<prio> ~~ 'important' {.<prio>}
                    default { 'normal' }
                }
            }

            if +(@child-types.unique) == 1 {
                # all of the same type
                given @child-types[0] {
                    when Handling {
                        if .Num == metadata{prop}<children> {
                            # all child properties need to be present
                            %prop-ast{$_}:delete for @children;
                            %prop-ast{prop} = { expr => [ :keyw($_) ] };
                        }
                    }
                    when 'important'|'normal' {
                        my %ast = expr => [ @children.map: {
                            my \sub-prop = %prop-ast{$_}:delete;
                            'expr:'~$_ => sub-prop<expr>;
                        } ];
                        %ast<prio> = $_
                            when $_ ~~ 'important';
                        %prop-ast{prop} = %ast;
                    }
                }
            }
        }
    }

    #| return an AST for the declarations.
    #| This more-or-less the inverse of CSS::Grammar::CSS3::declaration-list>
    #| and suitable for reserialization with CSS::Writer
    method ast(Bool :$optimize = True) {
        my %prop-ast;
        # '!important'
        for %!important.pairs {
            %prop-ast{.key}<prio> = 'important'
                if .value;
        }
        # 'initial', 'inherit'
        for %!handling.pairs {
            %prop-ast{.key}<expr> = [ :keyw(.value) ];
        }

        #| expressions
        for %!values.keys.sort -> \prop {
            with %!values{prop} -> \value {
                my \ast = self.to-ast: value;
                %prop-ast{prop}<expr> = [ ast ];
            }
        }

        self!optimize-ast: %prop-ast
            if $optimize;

        with %prop-ast<font> {
            # reinsert font '/' operator if needed...
            with .<expr> {
                # e.g.: font: italic bold 10pt/12pt times-roman;
                $_ = [ flat .map: { .key eq 'expr:line-height' ?? [ :op('/'), $_, ] !! $_ } ];
            }
        }

        #| assemble property list
        my @declaration-list = %prop-ast.keys.sort.map: -> \prop {
            my %property = %prop-ast{prop};
            %property.push: 'ident' => prop;
            %property;
        };
        
        :@declaration-list;
    }

    #| write a set of declarations. By default, it is formatted as a single-line,
    #| suited to an HTML inline-style (style attribute).
    method write(Bool :$optimize = True,
                 Bool :$terse = True,
                 Bool :$color-names = True,
                 |c) {
        my \writer = CSS::Writer.new( :$terse, :$color-names, |c);
        writer.write: self.ast(:$optimize);
    }

    method Str { self.write }

    #| return a list of properties
    proto method properties(|) {*}

    #| return all module properties
    multi method properties(Bool :$all! where .so) {
        keys %module-metadata{$!module};
    }

    #| return only populated properties
    multi method properties is default {
        keys %!values;
    }

    #| delete property values from the list of populated properties
    method delete(*@props) {
        for @props -> Str $prop {
            with self!metadata{$prop} {
                if .<box> {
                    $.delete($_) for .<edges>.list
                }
                if .<children> {
                    $.delete($_) for .<children>.list
                }
                %!values{$prop}:delete;
            }
        }
        self;
    }

    method can(Str \name) {
        my @meth = callsame;
        unless @meth {
            with self!metadata{name} {
                @meth.push: (
                    .<children>
                        ?? method () is rw { self!struct-value(name, .<children>) }
                        !! ( .<box>
                             ?? method () is rw { self!box-value(name, .<edges>) }
                             !! method () is rw { self!item-value(name) }
                           )
                      );
	
	        self.^add_method(name,  @meth[0]);
            }
        }
        @meth;
    }
    method dispatch:<.?>(\name, |c) is raw {
        self.can(name) ?? self."{name}"(|c) !! Nil
    }
    method FALLBACK(Str \name, |c) {
        self.can(name)
            ?? self."{name}"(|c)
            !! die die X::Method::NotFound.new( :method(name), :typename(self.^name) );
    }
}
