use v6;

class CSS::Grammar::AST {

    # These tables map AST types to standard W3C component definitions.

    # CSS object definitions based on http://dev.w3.org/csswg/cssom/
    # for example 6.4.1 CSSRuleList maps to CSSObject::RuleList
    our Str enum CSSObject is export(:CSSObject) «
        :CharsetRule<charset-rule>
        :FontFaceRule<fontface-rule>
        :GroupingRule<grouping-rule>
        :ImportRule<import>
        :MarginRule<margin-rule>
        :MediaRule<media-rule>
        :NamespaceRule<namespace-rule>
        :PageRule<page-rule>
        :Priority<prio>
        :RuleSet<ruleset>
        :RuleList<rule-list>
        :StyleDeclaration<style>
        :StyleRule<style-rule>
        :StyleSheet<stylesheet>
        »;

    # CSS value types based on http://dev.w3.org/csswg/cssom-values/
    # for example 3.3 CSSStyleDeclarationValue maps to CSSValue::StyleDeclaration
    our Str enum CSSValue is export(:CSSValue) «
        :ColorComponent<color>
        :Component<value>
        :IdentifierComponent<ident>
        :KeywordComponent<keyw>
        :LengthComponent<length>
        :Map<map>
        :PercentageComponent<percent>
        :Property<property>
        :PropertyList<declarations>
        :StringComponent<string>
        :URLComponent<url>

        :NameComponent<name>
        :NumberComponent<num>
        :IntegerComponent<int>
        :AngleComponent<angle>
        :FrequencyComponent<freq>
        :FunctionComponent<func>
        :ResolutionComponent<resolution>
        :TimeComponent<time>
        :QnameComponent<qname>
        :OtherUnitComponent<units>
        :NamespacePrefixComponent<ns-prefix>
        :ElementNameComponent<element-name>
        :OperatorComponent<op>
        :ExpressionComponent<expr>
        :ArgumentListComponent<args>
        :AtKeywordComponent<at-keyw>
        :UnicodeRangeComponent<unicode-range>
    »;

    # an enumerated list of all unit types for validation purposes.
    # Adapted from the out-of-date http://www.w3.org/TR/DOM-Level-2-Style/css.html

    our Str enum CSSUnits is export(:CSSUnits) «
        :ems<length> :exs<length> :px<length> :cm<length> :mm<length> :in<length> :pt<length> :pc<length>
        :em<length> :ex<length> :rem<length> :ch<length> :vw<length> :vh<length> :vmin<length> :vmax<length>
        :dpi<resolution> :dpcm<resolution> :dppx<resolution>
        :deg<angle> :rad<angle> :grad<angle> :turn<angle>
        :ms<time> :s<time>
        :hz<freq> :khz<freq>
        :rgb<color> :rgba<color> :hsl<color> :hsla<color>
    »;

    our Str enum CSSSelector is export(:CSSSelector) «
        :AttributeSelector<attrib>
        :Class<class>
        :Id<id>
        :MediaList<media-list>
        :MediaQuery<media-query>
        :PseudoClass<pseudo-class>
        :PseudoElement<pseudo-elem>
        :PseudoFunction<pseudo-func>
        :SelectorList<selectors>
        :Selector<selector>
        :SelectorComponent<simple-selector>
    »;

    # from http://dev.w3.org/csswg/cssom-view/
    our Str enum CSSTrait is export(:CSSTrait) «:Box<box>»;

BEGIN our %known-type =
    %( CSSObject.enums.invert ),
    %( CSSValue.enums.invert ),
    %( CSSSelector.enums.invert ),
    ;

BEGIN our %CSS21-Colors =
    black   => [   0,   0,   0 ],
    silver  => [ 192, 192, 192 ],
    gray    => [ 128, 128, 128 ],
    white   => [ 255, 255, 255 ],
    maroon  => [ 128,   0,   0 ],
    red     => [ 255,   0,   0 ],
    orange  => [ 255, 165,   0 ],
    purple  => [ 128,   0, 128 ],
    fuchsia => [ 255,   0, 255 ],
    green   => [   0, 128,   0 ],
    lime    => [   0, 255,   0 ],
    olive   => [ 128, 128,   0 ],
    yellow  => [ 255, 255,   0 ],
    navy    => [   0,   0, 128 ],
    blue    => [   0,   0, 255 ],
    teal    => [   0, 128, 128 ],
    aqua    => [   0, 255, 255 ],
    ;

# from http://www.w3.org/TR/2011/REC-css3-color-20110607
BEGIN our %CSS3-Colors =
    aliceblue       => [ 240,248,255 ],
    antiquewhite    => [ 250,235,215 ],
    aqua            => [ 0,255,255 ],
    aquamarine      => [ 127,255,212 ],
    azure           => [ 240,255,255 ],
    beige           => [ 245,245,220 ],
    bisque          => [ 255,228,196 ],
    black           => [ 0,0,0 ],
    blanchedalmond  => [ 255,235,205 ],
    blue            => [ 0,0,255 ],
    blueviolet      => [ 138,43,226 ],
    brown           => [ 165,42,42 ],
    burlywood       => [ 222,184,135 ],
    cadetblue       => [ 95,158,160 ],
    chartreuse      => [ 127,255,0 ],
    chocolate       => [ 210,105,30 ],
    coral           => [ 255,127,80 ],
    cornflowerblue  => [ 100,149,237 ],
    cornsilk        => [ 255,248,220 ],
    crimson         => [ 220,20,60 ],
    cyan            => [ 0,255,255 ],
    darkblue        => [ 0,0,139 ],
    darkcyan        => [ 0,139,139 ],
    darkgoldenrod   => [ 184,134,11 ],
    darkgray        => [ 169,169,169 ],
    darkgreen       => [ 0,100,0 ],
    darkgrey        => [ 169,169,169 ],
    darkkhaki       => [ 189,183,107 ],
    darkmagenta     => [ 139,0,139 ],
    darkolivegreen  => [ 85,107,47 ],
    darkorange      => [ 255,140,0 ],
    darkorchid      => [ 153,50,204 ],
    darkred         => [ 139,0,0 ],
    darksalmon      => [ 233,150,122 ],
    darkseagreen    => [ 143,188,143 ],
    darkslateblue   => [ 72,61,139 ],
    darkslategray   => [ 47,79,79 ],
    darkslategrey   => [ 47,79,79 ],
    darkturquoise   => [ 0,206,209 ],
    darkviolet      => [ 148,0,211 ],
    deeppink        => [ 255,20,147 ],
    deepskyblue     => [ 0,191,255 ],
    dimgray         => [ 105,105,105 ],
    dimgrey         => [ 105,105,105 ],
    dodgerblue      => [ 30,144,255 ],
    firebrick       => [ 178,34,34 ],
    floralwhite     => [ 255,250,240 ],
    forestgreen     => [ 34,139,34 ],
    fuchsia         => [ 255,0,255 ],
    gainsboro       => [ 220,220,220 ],
    ghostwhite      => [ 248,248,255 ],
    gold            => [ 255,215,0 ],
    goldenrod       => [ 218,165,32 ],
    gray            => [ 128,128,128 ],
    green           => [ 0,128,0 ],
    greenyellow     => [ 173,255,47 ],
    grey            => [ 128,128,128 ],
    honeydew        => [ 240,255,240 ],
    hotpink         => [ 255,105,180 ],
    indianred       => [ 205,92,92 ],
    indigo          => [ 75,0,130 ],
    ivory           => [ 255,255,240 ],
    khaki           => [ 240,230,140 ],
    lavender        => [ 230,230,250 ],
    lavenderblush   => [ 255,240,245 ],
    lawngreen       => [ 124,252,0 ],
    lemonchiffon    => [ 255,250,205 ],
    lightblue       => [ 173,216,230 ],
    lightcoral      => [ 240,128,128 ],
    lightcyan       => [ 224,255,255 ],
    lightgoldenrodyellow    => [ 250,250,210 ],
    lightgray       => [ 211,211,211 ],
    lightgreen      => [ 144,238,144 ],
    lightgrey       => [ 211,211,211 ],
    lightpink       => [ 255,182,193 ],
    lightsalmon     => [ 255,160,122 ],
    lightseagreen   => [ 32,178,170 ],
    lightskyblue    => [ 135,206,250 ],
    lightslategray  => [ 119,136,153 ],
    lightslategrey  => [ 119,136,153 ],
    lightsteelblue  => [ 176,196,222 ],
    lightyellow     => [ 255,255,224 ],
    lime            => [ 0,255,0 ],
    limegreen       => [ 50,205,50 ],
    linen           => [ 250,240,230 ],
    magenta         => [ 255,0,255 ],
    maroon          => [ 128,0,0 ],
    mediumaquamarine        => [ 102,205,170 ],
    mediumblue      => [ 0,0,205 ],
    mediumorchid    => [ 186,85,211 ],
    mediumpurple    => [ 147,112,219 ],
    mediumseagreen  => [ 60,179,113 ],
    mediumslateblue => [ 123,104,238 ],
    mediumspringgreen       => [ 0,250,154 ],
    mediumturquoise => [ 72,209,204 ],
    mediumvioletred => [ 199,21,133 ],
    midnightblue    => [ 25,25,112 ],
    mintcream       => [ 245,255,250 ],
    mistyrose       => [ 255,228,225 ],
    moccasin        => [ 255,228,181 ],
    navajowhite     => [ 255,222,173 ],
    navy            => [ 0,0,128 ],
    oldlace         => [ 253,245,230 ],
    olive           => [ 128,128,0 ],
    olivedrab       => [ 107,142,35 ],
    orange          => [ 255,165,0 ],
    orangered       => [ 255,69,0 ],
    orchid          => [ 218,112,214 ],
    palegoldenrod   => [ 238,232,170 ],
    palegreen       => [ 152,251,152 ],
    paleturquoise   => [ 175,238,238 ],
    palevioletred   => [ 219,112,147 ],
    papayawhip      => [ 255,239,213 ],
    peachpuff       => [ 255,218,185 ],
    peru            => [ 205,133,63 ],
    pink            => [ 255,192,203 ],
    plum            => [ 221,160,221 ],
    powderblue      => [ 176,224,230 ],
    purple          => [ 128,0,128 ],
    red             => [ 255,0,0 ],
    rosybrown       => [ 188,143,143 ],
    royalblue       => [ 65,105,225 ],
    saddlebrown     => [ 139,69,19 ],
    salmon          => [ 250,128,114 ],
    sandybrown      => [ 244,164,96 ],
    seagreen        => [ 46,139,87 ],
    seashell        => [ 255,245,238 ],
    sienna          => [ 160,82,45 ],
    silver          => [ 192,192,192 ],
    skyblue         => [ 135,206,235 ],
    slateblue       => [ 106,90,205 ],
    slategray       => [ 112,128,144 ],
    slategrey       => [ 112,128,144 ],
    snow            => [ 255,250,250 ],
    springgreen     => [ 0,255,127 ],
    steelblue       => [ 70,130,180 ],
    tan             => [ 210,180,140 ],
    teal            => [ 0,128,128 ],
    thistle         => [ 216,191,216 ],
    tomato          => [ 255,99,71 ],
    turquoise       => [ 64,224,208 ],
    violet          => [ 238,130,238 ],
    wheat           => [ 245,222,179 ],
    white           => [ 255,255,255 ],
    whitesmoke      => [ 245,245,245 ],
    yellow          => [ 255,255,0 ],
    yellowgreen     => [ 154,205,50 ],
    ;

    method token(Mu $ast, :$type is copy) {

        die 'usage: $.token($ast, :$type)'
            unless $type;

        return unless $ast.defined;

        my $units = $type;

        if $type.defined && (my $inferred-type = CSSUnits.enums{$type}) {
            $type = $inferred-type
        }

        if $type.defined {
            my $raw-type = $type.subst(/':'.*/,'');
            die "unknown type: '$raw-type'"
                unless %known-type{$raw-type}:exists;
        }

        my $token = $ast.isa(Pair)
            ?? Pair.new( :key($units.Str), :value($ast.value) )
            !! Pair.new( :key($units.Str), :value($ast) );

        return $token;
    }

    method node($/) {
        my %terms;

        # unwrap Parcels
        my @l = $/.can('caps')
            ?? ($/)
            !! $/.grep({ .defined });

        for @l {
            for .caps -> $cap {
                my ($key, $value) = $cap.kv;
                next if $key eq '0';
                $key = $key.lc;
                my ($type, $_class) = $key.split(':');

                $value = $value.ast
                    // next;

                if substr($key, 0, 5) eq 'expr-' {
                    $key = $key.subst(/^'expr-'/, 'expr:')
                }
                elsif $value.isa(Pair) {
                    ($key, $value) = $value.kv;
                }
                elsif %known-type{$type}:!exists {
                    warn "{$value.perl} has unknown type: $type";
                }

                if %terms{$key}:exists {
                    $.warning("repeated term " ~ $key, $value);
                    return Any;
                }

                %terms{$key} = $value;
            }
        }

        return %terms;
    }

    method list($/) {
        # make a node that contains repeatable elements
        my @terms;

        # unwrap Parcels
        my @l = $/.can('caps')
            ?? ($/)
            !! $/.grep({ .defined });

        for @l {
            for .caps -> $cap {
                my ($key, $value) = $cap.kv;
                next if $key eq '0';
                $key = $key.lc;

                my ($type, $_class) = $key.split(':');

                $value = $value.ast
                    // next;

                if substr($key, 0, 5) eq 'expr-' {
                    $key = $key.subst(/^'expr-'/, 'expr:')
                }
                elsif $value.isa(Pair) {
                    ($key, $value) = $value.kv;
                }
                elsif %known-type{$type}:!exists {
                    warn "{$value.perl} has unknown type: $type";
                }

                push( @terms, {$key => $value} );
            }
        }

        return @terms;
    }

}
