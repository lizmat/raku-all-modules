use v6;

unit grammar Test::Base::Grammar;

token TOP {
    \n*
    <block>*
}

token block-delim { '===' }
token data-delim { '---' }

token block {
    <.block-delim> ' '* <title> \n
    <data>*
}

token title { \N* }

proto token data { * }

token data:sym<single> {
    <.data-delim> \s* <key>  \s* ':' \s* $<value>=\N* \n+
}

token data:sym<multi> {
    <.data-delim> \s* <key> \N* \n # --- title
    $<value>=.*?
    <before <.data-delim> | <.block-delim> | $>
}

token key {
    <-[ \: \n ]>+
}

