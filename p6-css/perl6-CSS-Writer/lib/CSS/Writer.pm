use v6;

use CSS::Writer::BaseTypes;

class CSS::Writer
    is CSS::Writer::BaseTypes {

    use CSS::Grammar::AST;
    use CSS::Grammar::CSS3;

    has Str $.indent is rw;
    has Bool $.terse is rw;
    has Bool $.color-masks is rw;
    has %.color-values is rw;   #- maps color names to rgb values
    has %.color-names is rw;    #- maps rgb hex codes to named colors
    has $.ast is rw;

    submethod BUILD(:$!indent='',
                    :$!terse=False,
                    :$!color-masks=False,
                    :$color-names, :$color-values,
                    :$!ast,
        ) {

        sub build-color-names(%colors) {
            my %color-names;

            for %colors {
                my ($name, $rgb) = .kv;
                # output as ...gray not ...grey
                next if $name ~~ /grey/;
                my $hex = 256 * (256 * $rgb[0]  +  $rgb[1])  +  $rgb[2];
                %color-names{ $hex } = $name;
            }

            return %color-names;
        }

        if $!terse {
            $!color-masks //= True;
        }

        if $color-names.defined {
            die ":color-names and :color-values are mutually exclusive options"
                if $color-values;

            given $color-names {
                when Bool { %!color-names = build-color-names( %CSS::Grammar::AST::CSS3-Colors )
                                if $_; }
                when Hash { %!color-names = build-color-names( $_ ) }
                default {
                    die 'usage :color-names [for CSS3 Colors] or :color-names(%table) [e.g. :color-names(CSS::Grammar::AST::CSS3-Colors)]';
                }
            }
        }
        elsif $color-values.defined {
            given $color-values {
                when Bool { %!color-values = %CSS::Grammar::AST::CSS3-Colors
                                if $_; }
                when Hash { %!color-values = %$_ }
                default {
                    die 'usage :color-values [for CSS3 Colors] or :color-values(%table) [e.g. :color-values(CSS::Grammar::AST::CSS3-Colors)]';
                }
            }
        }

    }

    method Str {
        nextsame unless $.ast.defined;
        $.write( $.ast );
    }

    #| @top-left { margin: 5px; } :=   $.write( :at-keyw<top-left>, :declarations[ { :ident<margin>, :expr[ :px(5) ] } ] )
    multi method write( Str :$at-keyw!, List :$declarations! ) {
        ($.write( :$at-keyw ),  $.write( :$declarations)).join: ' ';
    }

    #| 42deg   := $.write( :angle(42), :units<deg>) or $.write( :deg(42) )
    multi method write( Numeric :$angle!, Any :$units? ) {
        $.write-num( $angle, $units );
    }

    #| @page   := $.write( :at-keyw<page> )
    multi method write( Str :$at-keyw! ) {
        '@' ~ $.write( :ident($at-keyw) );
    }

    #| 'foo', bar, 42 := $.write( :args[ :string<foo>, :ident<bar>, :num(42) ] )
    multi method write( List :$args! ) {
        $.write( $args, :sep(', ') );
    }

    #| [foo]   := $.write( :attrib[ :ident<foo> ] )
    multi method write( List :$attrib! ) {
        [~] '[', $attrib.map({ $.write( $_ ) }), ']';
    }

    #| @charset 'utf-8';   := $.write( :charset-rule<utf-8> )
    multi method write( Str :$charset-rule! ) {
        [~] '@charset ', $.write( :string($charset-rule) ), ';'
    }

    #| rgb(10, 20, 30) := $.write( :color[ :num(10), :num(20), :num(30) ], :units<rgb> )
    #| or $.write( :rgb[ :num(10), :num(20), :num(30) ] )
    multi method write( Any :$color!, Any :$units? ) {
        $.write-color( $color, $units );
    }

    #| /* These are */ /* comments * / */ := $.write( :comment["These are", "comments */"] )
    multi method write( List :$comment! ) {
        $comment.map({ $.write( :comment($_) ) }).join: $.nl;
    }
    multi method write( Str :$comment! where /^ <CSS::Grammar::CSS3::comment> $/ ) {
        $comment;
    }
    multi method write( Str :$comment! ) {
        [~] '/* ', $comment.trim.subst(/'*/'/, '* /'), ' */';
    }

    #| .my-class := $.write( :class<my-class> )
    multi method write( Str :$class!) {
        '.' ~ $.write( :name($class) );
    }

    #| { font-size: 12pt; color: white; } := $.write( :declarations[ { :ident<font-size>, :expr[ :pt(12) ] }, { :ident<color>, :expr[ :ident<white> ] } ] )
    multi method write( List :$declarations! ) {
        my @decls-indented =  $declarations.map: {
            my $prop = .<ident>:exists
                ?? %(property => $_)
                !! $_;

            $.write-indented( $prop, 2);
        };

        ('{', @decls-indented, $.indent ~ '}').join: $.nl;
    }

    #| h1 := $.write: :element-name<H1>
    multi method write( Str :$element-name! ) {
        given $element-name {
            when '*' {'*'}  # wildcard namespace
            default  { $.write( :ident( .lc ) ) }
        }
    }

    #| 'foo', bar+42 := $.write( :expr[ :string<foo>, :op<,>, :ident<bar>, :op<+>, :num(42) ] )
    multi method write( List :$expr! ) {
        my $sep = '';

        [~] $expr.map( -> $term is copy {

            $sep = '' if $term<op> && $term<op>;

            if %.color-values && ($term<ident>:exists) && my $rgb = %.color-values{ $term<ident>.lc } {
                # substitute a named color with it's rgb value
                $term = {rgb => $rgb.map({ num => $_})};
            }

            my $out = $sep ~ $.write($term);
            $sep = $term<op> && $term<op> ne ',' ?? '' !! ' ';
            $out;
        });
    }

    #| @font-face { src: 'foo.ttf'; } := $.write( :fontface-rule{ :declarations[ { :ident<src>, :expr[ :string<foo.ttf> ] } ] } )
    multi method write( Hash :$fontface-rule! ) {
        [~] '@font-face ', $.write( $fontface-rule, :nodes<declarations> );
    }

    #| 420hz   := $.write( :freq(420), :units<hz>) or $.write( :khz(.42) )
    multi method write( Numeric :$freq!, Str :$units ) {
        given $units {
            when 'hz' {$.write-num( $freq, 'hz' )}
            when 'khz' {$.write-num( $freq * 1000, 'hz' )}
            default {die "unhandled frequency unit: $units";}
        }
    }

    #| :lang(klingon) := $.write( :pseudo-func{ :ident<lang>, :args[ :ident<klingon> ] } )
    multi method write( Hash :$func!) {
        sprintf '%s(%s)%s', $.write( $func, :node<ident> ), do {
            when $func<args>:exists {$.write( $func, :node<args> )}
            when $func<expr>:exists {$.write( $func, :node<expr> )}
            default {''};
        },
        $.write-any-comments( $func, ' ' );
    }

    #| #My-id := $.write( :id<My-id> )
    multi method write( Str :$id!) {
        '#' ~ $.write( :name($id) );
    }

    #| -Moz-linear-gradient := $.write( :ident<-Moz-linear-gradient> )
    multi method write( Str :$ident! is copy) {
        my $pfx = $ident ~~ s/^"-"// ?? '-' !! '';
        my $minus = $ident ~~ s/^"-"// ?? '\\-' !! '';
        [~] $pfx, $minus, $.write( :name($ident) )
    }

    #| @import url('example.css') screen and (color); := $.write( :import{ :url<example.css>, :media-list[ { :media-query[ { :ident<screen> }, { :keyw<and> }, { :property{ :ident<color> } } ] } ] } )
    multi method write( Hash :$import! ) {
        [~] '@import ', $.write( $import, :nodes<url media-list>, :punc<;> );
    }

    #| 42 := $.write: :num(42)
    multi method write( Numeric :$int! ) {
        $.write-num( $int );
    }

    #| color := $.write: :keyw<Color>
    multi method write( Str :$keyw! ) {
        $keyw.lc;
    }

    #| 42mm   := $.write( :length(42), :units<mm>) or $.write( :mm(42) )
    multi method write( Numeric :$length!, Any :$units? ) {
        $.write-num( $length, $units );
    }

    #| @top-left { margin: 5px; } :=   $.write( :margin-rule{ :at-keyw<top-left>, :declarations[ { :ident<margin>, :expr[ :px(5) ] } ] } )
    multi method write( Hash :$margin-rule! ) {
        $.write( $margin-rule );
    }

    #| projection, tv := $.write( :media-list[ :ident<projection>, :ident<tv> ] )
    multi method write( List :$media-list! ) {
        $.write( $media-list, :sep(', ') );
    }

    #| screen and (color) := $.write( :media-query[ { :ident<screen> }, { :keyw<and> }, { :property{ :ident<color> } } ] )
    multi method write( List :$media-query! ) {
        join(' ', $media-query.map({
            my $css = $.write( $_ );

            if .<property> {
                # e.g. color:blue => (color:blue)
                $css = [~] '(', $css.subst(/';'$/, ''), ')';
            }

            $css
        }) );
    }

    #| @media all { body { background: lime; }} := $.write( :media-rule{ :media-list[ { :media-query[ :ident<all> ] } ], :rule-list[ { :ruleset{ :selectors[ :selector[ { :simple-selector[ { :element-name<body> } ] } ] ], :declarations[ { :ident<background>, :expr[ :ident<lime> ] } ] } } ]} )
    multi method write( Hash :$media-rule! ) {
        [~] '@media ', $.write( $media-rule, :nodes<media-list rule-list> );
    }

    #| hi\! := $.write( :name("hi\x021") )
    multi method write( Str :$name! ) {
        [~] $name.comb.map({
            when /<CSS::Grammar::CSS3::nmreg>/    { $_ };
            when /<CSS::Grammar::CSS3::regascii>/ { '\\' ~ $_ };
            default                               { .ord.fmt("\\%X ") }
        });
    }

    #| @namespace svg url('http://www.w3.org/2000/svg'); := $.write( :namespace-rule{ :ns-prefix<svg>, :url<http://www.w3.org/2000/svg> } )
    multi method write( Hash :$namespace-rule! ) {
        [~] '@namespace ', $.write( $namespace-rule, :nodes<ns-prefix url>, :punc<;> );
    }

    #| svg := $.write( :ns-prefix<svg> )
    multi method write( Str :$ns-prefix! ) {
        given $ns-prefix {
            when ''  {''}   # no namespace
            when '*' {'*'}  # wildcard namespace
            default  { $.write( :ident($_) ) }
        }
    }

    #| 42 := $.write( :num(42) )
    multi method write( Numeric :$num!, Any :$units? ) {
        $.write-num( $num, $units )
    }

    #| ~= := $.write( :op<~=> )
    multi method write( Str :$op! ) {
        $op.lc;
    }

    #| @page :first { margin: 5mm; } := $.write( :page-rule{ :pseudo-class<first>, :declarations[ { :ident<margin>, :expr[ :mm(5) ] } ] } )
    multi method write( Hash :$page-rule! ) {
    [~] '@page ', $.write( $page-rule, :nodes<pseudo-class declarations> );
    }

    #| 100% := $.write( :percent(100) )
    multi method write( :$percent! ) {
        $.write-num( $percent, '%' );
    }

    #| !important := $.write( :prio<important> )
    multi method write( Str :$prio! ) {
        '!' ~ $prio.lc;
    }

    #| color: red !important; := $.write( :property{ :ident<color>, :expr[ :ident<red> ], :prio<important> } )
    multi method write( Hash :$property! ) {
        my @p = $.write( $property, :node<ident> );
        @p.push: ': ' ~ $.write($property, :node<expr>)
            if $property<expr>:exists;
        @p.push: ' ' ~  $.write($property, :node<prio>)
            if $property<prio>:exists;
        @p.push: ';';
        my $comments = $.write-any-comments( $property, ' ' );
        @p.push: $comments if $comments;

        [~] @p;
    }

    #| :first := $.write: :pseudo-class<first>
    multi method write( Str :$pseudo-class! ) {
        ':' ~ $.write( :name($pseudo-class) );
    }

    #| ::first-letter := $.write: :pseudo-elem<first-letter>
    multi method write( Str :$pseudo-elem! ) {
        '::' ~ $.write( :name($pseudo-elem) );
    }

    #| :lang(klingon) := $.write( :pseudo-func{ :ident<lang>, :args[ :ident<klingon> ] } )
    multi method write( Hash :$pseudo-func! ) {
        ':' ~ $.write( :func($pseudo-func) );
    }

    #| svg|circle := $.write( :qname{ :ns-prefix<svg>, :element-name<circle> } )
    multi method write( Hash :$qname! ) {
        my $out = $.write($qname, :node<element-name>);

        $out = $.write($qname, :node<ns-prefix>) ~ '|' ~ $out
            if $qname<ns-prefix>:exists;

        $out ~= $.write-any-comments( $qname, ' ' );

        $out;
    }

    #| 600dpi   := $.write( :resolution(600), :units<dpi>) or $.write( :dpi(600) )
    multi method write( Numeric :$resolution!, Any :$units? ) {
        $.write-num( $resolution, $units );
    }

    #| { h1 { margin: 5pt; } h2 { margin: 3pt; color: red; }} := $.write( :rule-list[ { :ruleset{ :selectors[ :selector[ { :simple-selector[ { :element-name<h1> } ] } ] ], :declarations[ { :ident<margin>, :expr[ :pt(5) ] } ] } }, { :ruleset{ :selectors[ :selector[ { :simple-selector[ { :element-name<h2> } ] } ] ], :declarations[ { :ident<margin>, :expr[ :pt(3) ] }, { :ident<color>, :expr[ :ident<red> ] } ] } } ])
    multi method write( List :$rule-list! ) {
        '{ ' ~ $.write( $rule-list, :sep($.nl)) ~ '}';
    }

    #| a:hover { color: green; } := $.write( :ruleset{ :selectors[ :selector[ { :simple-selector[ { :element-name<a> }, { :pseudo-class<hover> } ] } ] ], :declarations[ { :ident<color>, :expr[ :ident<green> ] } ] } )
    multi method write( Hash :$ruleset! ) {
        [~] $.write($ruleset, :nodes<selectors declarations>);
    }

    #| #container * := $.write( :selector[ { :id<container>}, { :element-name<*> } ] )
    multi method write( List :$selector! ) {
        $.write( $selector );
    }

    #| h1, [lang=en] := $.write( :selectors[ :selector[ { :simple-selector[ { :element-name<h1> } ] } ], :selector[ :simple-selector[ { :attrib[ :ident<lang>, :op<=>, :ident<en> ] } ] ] ] )
    multi method write( List :$selectors! ) {
        $.write( $selectors, :sep(', ') );
    }

    #| .foo:bar#baz := $.write: :simple-selector[ :class<foo>, :pseudo-class<bar>, :id<baz> ]
    multi method write( List :$simple-selector! ) {
        $.write( $simple-selector, :sep("") );
    }

    #| 'I\'d like some \BEE f!' := $.write( :string("I'd like some \x[bee]f!") )
    multi method write( Str :$string! ) {
        $.write-string($string);
    }

    #| h1 { color: blue; } := $.write( :stylesheet[ { :ruleset{ :selectors[ { :selector[ { :simple-selector[ { :qname{ :element-name<h1> } } ] } ] } ], :declarations[ { :ident<color>, :expr[ { :ident<blue> } ] } ] } } ] )
    multi method write( List :$stylesheet! ) {
        my $sep = $.terse ?? "\n" !! "\n\n";
        $.write( $stylesheet, :$sep);
    }

    #| 20s := $.write( :time(20), :units<s> ) or $.write( :s(20) )
    multi method write( Numeric :$time!, Any :$units? ) {
        $.write-num( $time, $units );
    }

    #| U+A?? := $.write( :unicode-range[0xA00, 0xAFF] )
    multi method write( List :$unicode-range! ) {
        my $range;
        my ($lo, $hi) = $unicode-range.map: {sprintf("%X", $_)};

        if !$lo eq $hi {
            # single value
            $range = sprintf '%x', $lo;
        }
        else {
            my $lo-sub = $lo.subst(/0+$/, '');
            my $hi-sub = $hi.subst(/F+$/, '');

            if $lo-sub eq $hi-sub {
                $range = $hi-sub  ~ ('?' x ($hi.chars - $hi-sub.chars));
            }
            else {
                $range = [~] $lo, '-', $hi;
            }
        }

        'U+' ~ $range;
    }

    #| url('snoopy.jpg') := $.write( :url<snoopy.jpg> )
    multi method write( Str :$url! ) {
        sprintf "url(%s)", $.write-string( $url );
    }

    ## generic handling of Lists, Pairs, Hashs and Lists

    multi method write(List $ast, :$sep=' ') {
        my %sifted = classify { .isa(EnumMap) && (.<comment>:exists) ?? 'comment' !! 'elem' }, $ast.list;
        my $out = (%sifted<elem> // []).list.map({ $.write( $_ ) }).join: $sep;
        $out ~= [~] %sifted<comment>.list.map({ ' ' ~ $.write($_) })
            if %sifted<comment>:exists && ! $.terse;
        $out;
    }

    multi method write(Pair $ast) {
        $.write( |%$ast );
    }

    multi method write(Hash $ast!, :$node! ) {
        $.write( |($node => $ast{$node} ) );
    }

    multi method write(Hash $ast!, :$nodes!, Str :$punc='', Str :$sep=' ')  {
        my $str = $nodes.grep({ $ast{$_}:exists}).map({
                          $.write( |( .subst(/':'.*/, '') => $ast{$_}) )
                         }).join($sep)  ~  $punc;

        $str ~= $.write-any-comments( $ast, ' ' );

        $str;
    }

    multi method write(Hash $ast! ) {
        my %nodes =  $ast.keys.map: { .subst(/':'.*/, '') => $ast{$_} };
        $.write( |%nodes );
    }

    multi method write( *@args, *%opts ) is default {

        die "unexpected arguments: {[@args].perl}"
            if @args;

        use CSS::Grammar::AST :CSSUnits;
        for %opts.keys {
            if my $type = CSSUnits.enums{$_} {
                # e.g. redispatch $.write( :px(12) ) as $.write( :length(12), :units<px> )
                my %new-opts = $type => %opts{$_}, units => $_;
                return $.write( |%new-opts );
            }
        }
        
        die "unable to handle struct: {%opts.perl}"
    }

    # -- helper methods --

    #| write comments, if applicable
    method write-any-comments( $ast, $padding='' ) {
        $ast<comment>:exists && ! $.terse
            ?? $padding ~ $.write($ast, :node<comment>)
            !! ''
    }

    #| handle indentation.
    method write-indented( Any $ast, Int $indent!) {
        my $sp = '';
        temp $.indent;
        $.indent ~= ' ' x $indent
            unless $.terse;
        $.indent ~ $.write( $ast );
    }

    method nl {
        $.terse ?? ' ' !! "\n";
    }

}
