use v6;

# rules for constructing ASTs for CSS::Grammar, CSS::Grammar::CSS1,
# CSS::Grammar::CSS21 and CSS::Grammar::CSS3

use CSS::Grammar::AST :CSSObject, :CSSValue, :CSSUnits, :CSSSelector;

class X::CSS::Ignored { #is Exception { ## issue 4
    sub display-string(Str $str is copy --> Str) {

        $str = $str.chomp.trim;
## issue#4
##        $str ~~ s:g/[\s|\t|\n|\r|\f]+/ /;

##        [~] $str.comb.map: {
##                    /<[ \\ \t \s \!..\~ ]>/
##                        ?? $_  
##                        !! .ord.fmt("\\x[%x]")
##            };
    }

    has Str $!message is required;
    has Str $!str;
    has Str $!explanation;
    has UInt $.line-no;
    submethod BUILD( :$!message!, :$str, :$explanation, :$!line-no ) {
        $!str = display-string($_) with $str;
        $!explanation = display-string($_) with $explanation;
    }
    method message {
        my $warning = $!message;
        $warning ~= ': ' ~ $_ with $!str;
        $warning ~= ' - ' ~ $_ with $!explanation;
        $warning;
    }
    method Str {$.message}
}

class CSS::Grammar::Actions
    is CSS::Grammar::AST {

    has Int $.line-no is rw = 1;
    has Int $!eol-rachet = 0;
    # variable encoding - not yet supported
    has Str $.encoding is rw = 'UTF-8';
    has Bool $.lax is rw = False;

    # accumulated warnings
    has X::CSS::Ignored @.warnings;

    method reset {
        @.warnings = [];
        $.line-no = 1;
        $!eol-rachet = 0;
    }

    method at-rule($/, :$type) {
        warn "deprecated at-rule type: $_" with $type;
        my %terms = $.node($/);
        %terms{ CSSValue::AtKeywordComponent } //= $0.lc;
        return $.token( %terms, :type(CSSObject::AtRule));
    }

    method func(Str $name,
		$args,
		:$type     = CSSValue::FunctionComponent,
		:$arg-type = CSSValue::ArgumentListComponent,
		|c
	--> Pair) {
        my Pair $arg-tk = ($args.isa(List)
			   ?? ($arg-type => $args)
			   !! $args);
        my %ast = :ident($name), %$arg-tk;
        $.token( %ast, :$type, |c );
    }

    method pseudo-func( Str $ident, $expr --> Pair) {
        my %ast = :$ident, :$expr;
        $.token( %ast, :type(CSSSelector::PseudoFunction) );
    }

    method warning($message, $str?, $explanation?) {
        @.warnings.push: X::CSS::Ignored.new( :$message, :$str, :$explanation, :$.line-no);
    }

    method eol($/) {
        my $pos = $/.from;

        return
            if my $_backtracking = $pos <= $!eol-rachet;

        $!eol-rachet = $pos;
        $.line-no++;
    }

    method element-name($/)           { make $.token( $<Ident>.ast, :type(CSSValue::ElementNameComponent)) }

    method length-units:sym<abs>($/)  { make $/.lc }
    method length-units:sym<font>($/) { make $/.lc }

    method any($/) {}

    method dropped-decl:sym<forward-compat>($/) {
        $.warning('dropping term', ~$0) if $0;
        $.warning('dropping term', ~$1) if $1;
        $.warning('dropping declaration', .ast)
            with $<property>;
    }

    method dropped-decl($/) {
        $.warning('dropping term', ~$<any>)
            if $<any>;
        $.warning('dropping declaration', .ast)
            with $<property>;
    }

    method !to-unicode($hex-str --> Str) {
        my $char  = chr( :16($hex-str) );
        CATCH {
            default {
                $.warning('invalid unicode code-point', 'U+' ~ $hex-str.uc );
                $char = chr(0xFFFD); # �
            }
        }
        $char;
    }

    method unicode($/)  { make self!to-unicode(~$0) }

    method regascii($/) { make ~$/ }
    method nonascii($/) { make ~$/ }

    method escape($/)   { make $<char>.ast }

    method nmstrt($/)   { make $<char> ?? $<char>.ast !! ~$0}

    method nmchar($/)   { make $<char>.ast }

    method nmreg($/)    { make ~$/ }

    method Ident($/) {
        my $pfx = $<pfx> ?? ~$<pfx> !! '';
        my $ident = [~] flat $pfx, $<nmstrt>.ast, @<nmchar>.map( *.ast);
        make $ident.lc;
    }

    method name($/)  {
	my Str $name = [~] flat @<nmchar>.map( *.ast);
	make $.token( $name, :type(CSSValue::NameComponent));
    }
    method num($/)   { my $num = $/.Rat;
                       make $.token( $num % 1
                                     ?? $num
                                     !! $num.Int, :type(CSSValue::NumberComponent))
                     }
    method uint($/)  { make $/.Int }
    method op($/)    { make $/.lc  }

    method stringchar:sym<cont>($/)     { make '' }
    method stringchar:sym<escape>($/)   { make $<escape>.ast }
    method stringchar:sym<nonascii>($/) { make $<nonascii>.ast }
    method stringchar:sym<ascii>($/)    { make ~$/ }

    method single-quote($/) { make "'" }
    method double-quote($/) { make '"' }

    method !string-token($/ --> Pair) {
        my $string = [~] $<stringchar>>>.ast;
        make $.token($string, :type(CSSValue::StringComponent));
    }

    proto method string {*}
    method string:sym<single-q>($/) { self!string-token($/) }

    method string:sym<double-q>($/) { self!string-token($/) }

    method badstring($/) {
        $.warning('unterminated string', ~$/);
    }

    method id($/)    { make $.token( $<name>.ast, :type(CSSSelector::Id)) }

    method class($/) { make $.token( $<name>.ast, :type(CSSSelector::Class)) }

    method url-unquoted-char($/) {
        make $<char> ?? $<char>.ast !! ~$/
    }

    method url-unquoted($/) {
        make [~] $<url-unquoted-char>>>.ast;
    }

    method url($/)   {
        make $.token( $<url>.ast, :type(CSSValue::URLComponent));
    }

    # uri - synonym for url?
    method uri($/)   { make $<url>.ast }

    method any-dimension($/) {
        return $.warning("unknown units: { $<units:unknown>.ast }")
            unless $.lax;
        make $.node( $/ )
    }

    method color-range($/) {
        my $range = $<num>.ast.value;
        $range *= 2.55
            if ~$<percentage>;

        # clip out-of-range colors, see
        # http://www.w3.org/TR/CSS21/syndata.html#value-def-color
        $range = min( max($range, 0), 255);
        make $.token( $range.round, :type(CSSValue::NumberComponent));
    }

    proto method color {*}
    method color:sym<rgb>($/)  {
        return $.warning('usage: rgb(c,c,c) where c is 0..255 or 0%-100%')
            if $<any-args>;

        make $.token( $.list($/), :type<rgb>);
    }

    method color:sym<hex>($/)   {
        my $id = $<id>.ast.value;
        my $chars = $id.chars;

        return $.warning("bad hex color", ~$/)
            unless ($chars == 3|6);
# issue#4
## && $id.match(/^<xdigit>+$/)

        my @rgb = $chars == 3
            ?? $id.comb.map({$^hex-digit ~ $^hex-digit})
            !! (0, 2, 4).map({ $id.substr($_, 2) });

        my $num-type = CSSValue::NumberComponent;
        my @color = @rgb.map: { $num-type.Str => :16($_) };

        make $.token( @color, :type<rgb>);
    }

    method prio($/) {
        return $.warning("dropping term", ~$/)
            if $<any> || !$0;

        make $0.lc
    }

    # from the TOP (CSS1 + CSS21 + CSS3)
    method TOP($/) { make $<stylesheet>.ast }
    method stylesheet($/) { make $.token( $.list($/), :type(CSSObject::StyleSheet)) }

    method charset($/)   { make $.at-rule($/) }
    method import($/)    { make $.at-rule($/) }
    method url-string($/){ make $.token($<string>.ast, :type(CSSValue::URLComponent)) }

    method misplaced($/) {
        $.warning('ignoring out of sequence directive', ~$/)
    }

    method operator($/) { make $.token( ~$/, :type(CSSValue::OperatorComponent)) }

    # pseudos
    method pseudo:sym<:element>($/)  { make $.token( $<element>.lc, :type(CSSSelector::PseudoElement)) }
    method pseudo:sym<::element>($/) { make $.token( $<element>.lc, :type(CSSSelector::PseudoElement)) }
    method pseudo:sym<function>($/)  { make $<pseudo-function>.ast }
    method pseudo:sym<class>($/)     { make $.token( $<class>.ast, :type(CSSSelector::PseudoClass)) }

    # combinators
    method combinator:sym<adjacent>($/) { make '+' }
    method combinator:sym<child>($/)    { make '>' }
    method combinator:sym<not>($/)      { make '-' } # css21

    method !code-point(Str $hex-str --> Int) {
        return :16( ~$hex-str );
    }

    method unicode-range($/) {
        my Str ($lo, $hi);

        if $<mask> {
            my $mask = ~$<mask>;
            $lo = $mask.subst('?', '0'):g;
            $hi = $mask.subst('?', 'F'):g;
        }
        else {
            $lo = ~$<from>;
            $hi = ~$<to>;
        }

        make $.token( [ self!code-point( $lo ), self!code-point( $hi ) ], :type(CSSValue::UnicodeRangeComponent));
    }

    # css21/css3 core - media support
    method at-rule:sym<media>($/) { make $.at-rule($/) }
    method rule-list($/)          { make $.token( $.list($/), :type(CSSObject::RuleList)) }
    method media-list($/)         { make $.list($/) }
    method media-query($/)        { make $.list($/) }
    method media-name($/)         { make $.token( $<Ident>.ast, :type(CSSValue::IdentifierComponent)) }

    # css21/css3 core - page support
    method at-rule:sym<page>($/)  { make $.at-rule($/) }
    method page-pseudo($/)        { make $.token( $<Ident>.ast, :type(CSSSelector::PseudoClass)) }

    method property($/)           { make $<Ident>.ast }
    method ruleset($/)            { make $.token( $.node($/), :type(CSSObject::RuleSet)) }
    method selectors($/)          { make $.token( $.list($/), :type(CSSSelector::SelectorList)) }
    method declarations($/)       { make $.token( $<declaration-list>.ast, :type(CSSValue::PropertyList) ) }
    method declaration-list($/)   { make [($<declaration>>>.ast).grep: {.defined}] }
    method declaration($/)        { make $<any-declaration>.ast }
    method at-keyw($/)            { make $<Ident>.ast }
    method any-declaration($/)    {
        return if $<dropped-decl>;

        return make $.at-rule($/)
            if $<declarations>;

        return $.warning('dropping declaration', $<Ident>.ast)
            if !$<expr>.caps
            || $<expr>.caps.first({! .value.ast.defined});

        make $.token($.node($/), :type(CSSValue::Property));
    }

    method term($/) { make $<term>.ast }

    method expr($/) { make $.token( $.list($/), :type(CSSValue::ExpressionComponent)) }
    method term1:sym<percentage>($/) { make $<percentage>.ast }

    method term2:sym<dimension>($/)  { make $<dimension>.ast }
    method term2:sym<function>($/)   { make $.token( $<function>.ast, :type(CSSValue::FunctionComponent)) }

    proto method length {*}
    method length:sym<dim>($/) { make $.token($<num>.ast, :type($<units>.ast)); }
    method dimension:sym<length>($/) { make $<length>.ast }
    method length:sym<rel-font-length>($/) { make $<rel-font-length>.ast }
    method rel-font-length($/) {
        my $num = $<sign> && ~$<sign> eq '-' ?? -1 !! +1;
        make $.token($num, :type( $<rel-font-units>.lc ));
    }

    proto method angle {*}
    method angle-units($/)         { make $/.lc }
    method angle:sym<dim>($/)      { make $.token( $<num>.ast, :type($<units>.ast)) }
    method dimension:sym<angle>($/){ make $<angle>.ast }

    proto method time {*}
    method time-units($/)          { make $/.lc }
    method time:sym<dim>($/)       { make $.token( $<num>.ast, :type($<units>.ast)) }
    method dimension:sym<time>($/) { make $<time>.ast }

    proto method frequency {*}
    method frequency-units($/)     { make $/.lc }
    method frequency:sym<dim>($/)  { make $.token( $<num>.ast, :type($<units>.ast)) }
    method dimension:sym<frequency>($/) { make $<frequency>.ast }

    method percentage($/)          { make $.token( $<num>.ast, :type(CSSValue::PercentageComponent)) }

    method term1:sym<string>($/)   { make $.token( $<string>.ast, :type(CSSValue::StringComponent)) }
    method term1:sym<url>($/)      { make $.token( $<url>.ast, :type(CSSValue::URLComponent)) }
    method term1:sym<color>($/)    { make $<color>.ast }

    method term1:sym<num>($/)      { make $.token( $<num>.ast, :type(CSSValue::NumberComponent)); }
    method term1:sym<ident>($/)    { make $<Ident>
                                         ?? $.token( $<Ident>.ast, :type(CSSValue::IdentifierComponent)) 
                                         !! $<rel-font-length>.ast
                                   }

    method term1:sym<unicode-range>($/) { make $.node($/, :type(CSSValue::UnicodeRangeComponent)) }

    method selector($/)            { make $.token( $.list($/), :type(CSSSelector::Selector)) }

    method universal($/)           { make $.token( {element-name => ~$/}, :type(CSSValue::QnameComponent)) }
    method qname($/)               { make $.token( $.node($/), :type(CSSValue::QnameComponent)) }
    method simple-selector($/)     { make $.token( $.list($/), :type(CSSSelector::SelectorComponent)) }

    method attrib($/)              { make $.list($/) }

    method any-function($/) {
        return $.warning('skipping function arguments', ~$_)
            with $<any-args>;
        make $.node($/);
    }

    method pseudo-function:sym<lang>($/) {
        return $.warning('usage: lang(ident)')
            with $<any-args>;
        make $.pseudo-func( 'lang' , $.list($/) );
    }

    method any-pseudo-func($/) {
        make $.token( .ast, :type(CSSSelector::PseudoFunction) )
            with $<any-function>;
    }

    # css 2.1 attribute selectors
    method attribute-selector:sym<equals>($/)    { make ~$/ }
    method attribute-selector:sym<includes>($/)  { make ~$/ }
    method attribute-selector:sym<dash>($/)      { make ~$/ }
    # css 3 attribute selectors
    method attribute-selector:sym<prefix>($/)    { make ~$/ }
    method attribute-selector:sym<suffix>($/)    { make ~$/ }
    method attribute-selector:sym<substring>($/) { make ~$/ }
    method attribute-selector:sym<column>($/)    { make ~$/ }

    # An+B microsyntax
    method op-sign($/) { make ~$/ }
    method op-n($/)    { make 'n' }

    method AnB-expr:sym<keyw>($/) { make [ $.token( $<keyw>.ast, :type(CSSValue::KeywordComponent)) ] }
    method AnB-expr:sym<expr>($/) { make $.list($/) }

    method end-block($/) {
        $.warning("no closing '}'")
            unless $<closing-paren>;
    }

    method unclosed-comment($/) {
        $.warning('unclosed comment at end of input');
    }

    method unclosed-paren-square($/) {
        $.warning("no closing ']'");
    }

    method unclosed-paren-round($/) {
        $.warning("no closing ')'");
    }

    method unknown($/) {
        $.warning('dropping', ~$/)
    }
}
