# a grammar for parsing CSS property specifications in value definition syntax.
# references:
#  http://www.w3.org/TR/CSS21/about.html#property-defs
#  http://dev.w3.org/csswg/css-values/#value-defs
#  https://developer.mozilla.org/en-US/docs/Web/CSS/Value_definition_syntax

use CSS::Grammar::CSS3;

grammar CSS::Specification:ver<000.04> {
    rule TOP { <property-spec> * }

    rule property-spec {
        :my @*PROP-NAMES = [];
        <prop-names>
            \t <spec>
            \t [:i 'n/a' | ua specific | <-[ \t ]>*? properties || $<default>=<-[ \t ]>* ]
            [ \t <-[ \t ]>*? # applies to
              \t [<inherit=.yes>|<inherit=.no>]? ]?
    }
    rule spec          { :my $*CHOICE; <terms> }
    # possibly tab delimited. Assume one spec per line.
    token ws {<!ww>' '*}

    rule yes         {:i yes }
    rule no          {:i no}

    token prop-sep   {<[\x20 \, \*]>+}
    token prop-names {
        [
          [<.quote> <id> <.quote> | <id>]
          { @*PROP-NAMES.push: ~$<id> }
        ] +%% <.prop-sep>
    }
    token id         { <[a..z]>[\w|\-]* }
    token quote      {< ' ‘ ’ >}
    token id-quoted  { <.quote> <id> <.quote> }
    rule keyw        { <id> }
    rule digits      { \d+ }

    rule terms         { <term=.term-options>+ }
    rule term-options  { <term=.term-combo>    +% '|'  }
    rule term-combo    { <term=.term-required> +% '||' }
    rule term-required { <term=.term-values>   +% '&&' }
    rule term-values   { <term>+ }
    rule term          { <value><occurs>? }

    proto token occurs {*}
    token occurs:sym<maybe>       {'?'}
    token occurs:sym<once-plus>   {'+'}
    token occurs:sym<zero-plus>   {'*'}
    token occurs:sym<range>       {<range>}
    token occurs:sym<list>        {'#'<range>?}
    token range                   {'{'~'}' [ <min=.digits> [',' <max=.digits>]? ] }

    proto rule value {*}
    rule value:sym<func>          { <id>'(' ~ ')' <.terms> }
    rule value:sym<keywords>      { [<keyw><!before <occurs>>] +% '|' }
    rule value:sym<numbers>       { [<digits><!before <occurs>>] +% '|' }
    rule value:sym<keyw-quant>    { <keyw><occurs> }
    rule value:sym<num-quant>     { <digits><occurs> }
    rule value:sym<group>         { '[' ~ ']' <terms> }
    rule value:sym<rule>          { '<'~'>' <id> }
    rule value:sym<op>            { < , / = > }
    rule value:sym<prop-ref>      { <property-ref> }

    proto token property-ref      {*}
    token property-ref:sym<css21> { <id=.id-quoted> }
    token property-ref:sym<css3>  { '<'~'>' <id=.id-quoted> }

}
