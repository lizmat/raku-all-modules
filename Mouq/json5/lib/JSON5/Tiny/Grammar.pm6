use v6;
grammar JSON5::Tiny::Grammar;

rule TOP        { ^ [ <object> | <array> ] $ }
rule object     { '{' ~ '}' <pairlist>       }
rule pairlist   { <pair> * %% \,             }
rule pair       { <key> ':' <value>          }
rule array      { '[' ~ ']' <arraylist>      }
rule arraylist  {  <value> * %% [ \, ]       }

token ws { [ \s+ | <comment> ]* }
proto token comment {*};
token comment:line  {
    '//' \N*
}
token comment:block {
    '/*' [ <!before '*/'> . ]* '*/'
}

proto token value {*};
token value:object  { <object> };
token value:array   { <array>  };
token value:string  { <string> }
# TODO: When Rakudo supports it, these
# should really be value:number:int, etc
token value:int     { <[+-]>? [ 0 | <[1..9]> <[0..9]>* ] }
token value:num     {
    <[+-]>?
    [ 0 | <[1..9]> <[0..9]>* ]?
    \.
    <[0..9]>*
}
token value:exp     {
    ( # TODO: <value:int> | <value:num> when Rakudo supports it
      <[+-]>?
      [ 0 | <[1..9]> <[0..9]>* ]?
      [ \. <[0..9]>* ]?
    )
    <[eE]>
    ( <[+-]>? <[0..9]>+ )
}
token value:inf     { <[+-]>? Infinity }
token value:hex     { 0x <[a..zA..Z0..9]>+ }
token value:sym<true>  { <sym> };
token value:sym<false> { <sym> };
token value:sym<null>  { <sym> };

token key { <string> | <js-ident> }

token js-ident { <:alpha+[_$]> <:alpha+[_$]+[0..9]>* }

proto token string {*}
token string:dbqt {
    \" ~ \"
    [
    | <str>                | $<str>=\'
    | \\ [ <str=.str_escape> | $<str>=\" ]
    ]*
}
token string:apos {
    \' ~ \'
    [
    | <str>                | $<str>=\"
    | \\ [ <str=.str_escape> | $<str>=\' ]
    ]*
}

token str {
    <-['"\\\t\n]>+
}

token str_escape {
    <['"\\/bfnrt\n]> | u <xdigit>**4
}

# vim: ft=perl6
