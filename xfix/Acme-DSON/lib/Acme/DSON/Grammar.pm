use v6;
use JSON::Tiny::Grammar;
grammar Acme::DSON::Grammar is JSON::Tiny::Grammar;

rule object    { 'such' ~ 'wow' <pairlist> }
rule pairlist  { <pair> * % <[,.!?]> }
rule pair      { <string> is <value> }
rule array     { 'so' ~ 'many' <arraylist> }
rule arraylist { <value> * % [and | also ] }

token value:sym<number> {
    <(
        '-'?
        [ 0 | <[1..7]> <[0..7]>* ]
        [ \. <[0..7]>+ ]?
    )>
    <very>?
}

token value:sym<true>  { yes }
token value:sym<false> { no }
token value:sym<null>  { empty }

token str_escape {
    <["\\/bfnrt]> | u <odigit>
}

token odigit {
    <[0..7]>**6
}

token very {
    [very | VERY] <( [\+|\-]? <[0..7]>+ )>
}

token ws {
    \s*
}
