use v6;
unit grammar JSON::Hjson::Grammar;

token TOP { <ws-c> [ <root-object> | <value> ] <ws-c> }

token ws-c { [ <[\x20\t\n\r]> | <comment> ]* }

token name                { <json-string> | <non-punctuator-char>+ }
token non-punctuator-char { <-[\x20\t\n\r,:\[\]{}>]> }

token object      { '{' <ws-c> <memberlist> <ws-c> '}' }
token member      { <name> <ws-c> ':' <ws-c> <value> }
token memberlist  { <member>* %% <value-separator> }
token root-object { <member>+ %% <value-separator> }
token array       { '[' <ws-c> <arraylist> <ws-c> ']' }
token arraylist   { <value>* %% <value-separator> }

token value-separator {
    [ <ws-c> ',' | [ [ <[\x20\t\r]> | <comment> ]* \n ] ] <ws-c>
}

proto token value {*}
token value:sym<true>   { <sym> <!before <literal-end>> }
token value:sym<false>  { <sym> <!before <literal-end>> }
token value:sym<null>   { <sym> <!before <literal-end>> }
token value:sym<object> { <object> }
token value:sym<array>  { <array> }
token value:sym<number> {
    '-'?
    [ 0 | <[1..9]> <[0..9]>* ]
    [ \. <[0..9]>+ ]?
    [ <[eE]> [\+|\-]? <[0..9]>+ ]?
    <!before <num-end>>
}
token value:sym<string> { <string> }

token literal-end { <[\x20\t]>* <-[\n\r#/,[\]{}]> }
token num-end     { <[\x20\t]>* <-[\n\r#/,[\]{}]> }

proto token string {*}
token string:sym<json-string>      { <json-string> }
token string:sym<multiline-string> { "'''" ~ "'''" .*? }
token string:sym<quoteless-string> {
    <non-punctuator-char> <ql-char>*? <before <ql-end>>
}

token ql-char { <-[\n\r]> }
token ql-end  { <[\x20\t\r]>* \n | $ }

token json-string { \" ~ \" [ <str> | \\ <str=.str_escape> ]* }

token str        { <-["\\\t\n]>+ }
token str_escape { <["\\/bfnrt]> | 'u' <utf16_codepoint>+ % '\u' }

token utf16_codepoint { <.xdigit>**4 }

token comment {
    [ [ '#' | '//' ] <-[\n]>* ] | [ '/*' ~ '*/' .*? ]
}
