use v6;
# use Grammar::Tracer;

unit module Fortran::Grammar;
    
# basic Fortran structures
grammar FortranBasic is export { 

    # ignorable whitespace
    token comment { "!" \N* $$ }
    token ws { 
        <!ww> 
        \h* 
        ["&" \h* [ <comment>? <nl> ] + \h* "&" \h*] ? 
        <comment> ?
        }
    token nl { \n+ }

    # fortran primitives
    token name { :i <[a..z0..9_]>+ }
    token precision-spec { _ <name> }
    token digits { \d+ }
    token integer { <digits> <precision-spec> ? }
    token float { <digits> \. <digits>  <precision-spec> ? }
    token number { <sign>? [ <float> || <integer> ] }
    rule  string { [ '"' <-["]>* '"' ] || [ "'" <-[']>* "'" ] }
    rule  sign { <[-+]> }
    token atomic { <number> || <string> }
    rule  in-place-array { \( \/ [ <strings> || <numbers> ] \/ \) }
    token array-index-region { <value-returning-code> ? \: <value-returning-code> ? }
    token in-place { <atomic> || <in-place-array> }
    rule  strings { <string> [ \, <string> ] * }
    rule  numbers { <number> [ \, <number> ] * }

    token array-index { <array-index-region> || <integer> || <name> }
    rule  array-indices { <array-index> [ \, <array-index> ] *  }
    rule  indexed-array { <name> \( <array-indices> \) }
    rule  accessed-variable { <sign>? [ <indexed-array> || <name> ] }

    proto token operator { <...> }
    token operator:sym<\+>   { '+' }
    token operator:sym<\->   { '-' }
    token operator:sym<\*>   { '*' }
    token operator:sym<\/>   { '/' }
    token operator:sym<\*\*> { '**' }

    rule statement { 
        <value-returning-code> [ <operator> <value-returning-code> ] * }

    token argument { <value-returning-code> } # any value returning code can be an argument
    rule  arguments { <argument> [ \, <argument> ] * } # a list of arguments

    rule  function-call { <name> \( <arguments> ? \) }
    rule  subroutine-call { :i call <name> [ \( <arguments> ? \) ] ? }

    rule  value-returning-code { 
           <function-call> 
        || <in-place> 
        || <accessed-variable> 
        }
    }


