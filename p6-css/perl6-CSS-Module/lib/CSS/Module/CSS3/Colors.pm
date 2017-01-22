use v6;

# CSS3 Color Module Extensions
# specification: http://www.w3.org/TR/2011/REC-css3-color-20110607/

grammar CSS::Module::CSS3::Colors:ver<20110607.000> {

# extensions for CSS3 Color Module

# http://www.w3.org/TR/2011/REC-css3-color-20110607
# @color-profile is in the process of being dropped
##    rule at-rule:sym<color-profile> {(:i'color-profile') <declarations> }

    proto rule color {*}
    rule color:sym<named>
    {:i [aliceblue | antiquewhite | aqua |  aquamarine | azure | beige | bisque
         | black |  blanchedalmond |  blue | blueviolet  | brown |  burlywood |
         cadetblue | chartreuse | chocolate | coral | cornflowerblue | cornsilk
         | crimson |  cyan | darkblue |  darkcyan | darkgoldenrod  | darkgray |
         darkgreen  | darkgrey  | darkkhaki  | darkmagenta  |  darkolivegreen |
         darkorange  |  darkorchid |  darkred  |  darksalmon  | darkseagreen  |
         darkslateblue  |  darkslategray  |  darkslategrey  |  darkturquoise  |
         darkviolet | deeppink | deepskyblue | dimgray | dimgrey | dodgerblue |
         firebrick  |  floralwhite  |  forestgreen  |  fuchsia  |  gainsboro  |
         ghostwhite |  gold | goldenrod | gray  | green | greenyellow  | grey |
         honeydew | hotpink  | indianred | indigo | ivory |  khaki | lavender |
         lavenderblush |  lawngreen | lemonchiffon  | lightblue |  lightcoral |
         lightcyan | lightgoldenrodyellow |  lightgray | lightgreen | lightgrey
         | lightpink   |   lightsalmon  |   lightseagreen   |  lightskyblue   |
         lightslategray | lightslategrey |  lightsteelblue | lightyellow | lime
         | limegreen | linen | magenta | maroon | mediumaquamarine | mediumblue
         | mediumorchid  | mediumpurple  | mediumseagreen  |  mediumslateblue |
         mediumspringgreen | mediumturquoise | mediumvioletred | midnightblue |
         mintcream  | mistyrose |  moccasin |  navajowhite |  navy |  oldlace |
         olive  | olivedrab |  orange |  orangered |  orchid |  palegoldenrod |
         palegreen |  paleturquoise | palevioletred | papayawhip  | peachpuff |
         peru | pink | plum | powderblue | purple | red | rosybrown | royalblue
         | saddlebrown | salmon  | sandybrown | seagreen |  seashell | sienna |
         silver  |  skyblue  | slateblue  |  slategray  |  slategrey |  snow  |
         springgreen | steelblue | tan |  teal | thistle | tomato | turquoise |
         violet | wheat | white | whitesmoke | yellow | yellowgreen
         ] & <keyw> }

    rule color:sym<current> {:i currentColor & <keyw> }
    rule color:sym<transparent> {:i transparent & <keyw> }

    rule color-angle{<number>}
    rule color-alpha{<number><!before '%'>}

    # <rgb> and <hex> are defined in CSS core grammar
    #| usage: rgba(c,c,c,a) where c is 0..255 or 0%-100% and a is 0-1 or 0%-100%
    rule color:sym<rgba> {:i'rgba('
                              [ <c=.color-range> ','
                                <c=.color-range> ','
                                <c=.color-range> ','
                                <c=.color-alpha> || <usage(&?ROUTINE.WHY)> ]
                   ')'
    }

    rule percentage-range {<percentage>|<color-alpha>}

    #| usage: hsl(h,s,l) where h is 0..360  and s,l are 0-1 or 0%-100%
    rule color:sym<hsl> {:i'hsl('
                             [ <c=.color-angle> ','
                               <c=.percentage-range> ','
                               <c=.percentage-range> || <usage(&?ROUTINE.WHY)> ]
                    ')'
    }

    #| usage: hsla(h,s,l,a) where h is 0..360  and s,l,a are 0-1 or 0%-100%
    rule color:sym<hsla> {:i'hsla('
                              [ <c=.color-angle> ','
                                <c=.percentage-range> ','
                                <c=.percentage-range> ','
                                <c=.percentage-range> || <usage(&?ROUTINE.WHY)> ]
                   ')'
    }

}

class CSS::Module::CSS3::Colors::Actions {

    use CSS::Grammar::AST :CSSValue;

    method colors { %CSS::Grammar::AST::CSS3-Colors }

    method color-angle($/) {
        make $<number>.ast;
    }

    method color-alpha($/) {
        my Numeric $alpha = $<number>.ast.value;
        $alpha = 0.0 if $alpha < 0.0;
        $alpha = 1.0 if $alpha > 1.0;
        make $.token($alpha, :type(CSSValue::NumberComponent));
    }

    method percentage-range($/) {
        return make $<color-alpha>.ast
            if $<color-alpha>;
        my Numeric $percentage = $<percentage>.ast.value;
        $percentage = 0 if $percentage < 0;
        $percentage = 100 if $percentage > 100;
        make $.token($percentage, :type(CSSValue::PercentageComponent))
    }

    method color:sym<rgba>($/) {
        return $.warning( $<usage>.ast ) if $<usage>;
        make $.token( $.list($/), :type<rgba>);
    }

    method color:sym<hsl>($/)  {
        return $.warning( $<usage>.ast ) if $<usage>;
        make $.token( $.list($/), :type<hsl>);
    }

    method color:sym<hsla>($/) {
        return $.warning( $<usage>.ast ) if $<usage>;
        make $.token( $.list($/), :type<hsla>);
    }

    method color:sym<current>($/) {
        make $<keyw>.ast;
    }

    method color:sym<transparent>($/) {
        make $<keyw>.ast;
    }

}

