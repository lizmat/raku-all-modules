use v6.c;
unit grammar Xmav::JSON::Grammar;

token TOP { \s* <json-value> \s* }

proto token json-value       { * }
token json-value:sym<true>   { <sym> }
token json-value:sym<false>  { <sym> }
token json-value:sym<null>   { <sym> }
token json-value:sym<string> { <json-string> }
token json-value:sym<number> { <json-number> }
token json-value:sym<array>  { <json-array> }
token json-value:sym<object> { <json-object> }

token json-string { '"' ~ '"' <string-char>* }
rule json-object  { '{' ~ '}' [ <object-pair>* % ',' ]? }
rule json-array   { '[' ~ ']' [ <json-value>* % ',' ]? }
token json-number { '-'? [ <[\d]-[0]>\d* <frac-part>? | '0'? <frac-part> | '0' ] <exp-part>? }

token frac-part  { '.' \d+ }
token exp-part   { <[eE]> <[+-]>? \d+ }

proto token string-char        { * }
token string-char:sym<escape>  { <escape-char> }
token string-char:sym<regular> { <regular-char> }

proto token escape-char        { * }
token escape-char:sym<single>  { <backslash-char> }
token escape-char:sym<unicode> { <unicode-char> }
token backslash-char           { '\\' <[\" \\ \/ b f n r t]> }
token unicode-char             { '\\u' <xdigit> ** 4 }
token regular-char             { <-[\\ \" \x00 .. \x1F ]> }

rule object-pair { <json-string> ':' <json-value> }
