use v6;

grammar CSS::Grammar::Core{...}

# based on http://www.w3.org/TR/2011/REC-CSS2-20110607
grammar CSS::Grammar:ver<0.3.2> {

    # abstract base grammar for CSS instance grammars:
    #  CSS::Grammar::CSS1  - CSS level 1
    #  CSS::Grammar::CSS21 - CSS level 2.1
    #  CSS::Grammar::CSS3  - CSS level 3

    # Comments and whitespace

    token comment {('<!--') .*? ['-->' || <unclosed-comment>]
                  |('/*')   .*? ['*/'  || <unclosed-comment>]}
    token unclosed-comment {$}

    token wc { \n | "\t"  | " " }
    token ws { <!ww>[ <.wc> | <.comment> ]* }

    # "lexer"
    # taken from http://www.w3.org/TR/css3-syntax/ 11.2 Lexical Scanner

    token unicode  { (<xdigit>**1..6) <.wc>? }
    # w3c nonascii :== #x80-#xD7FF #xE000-#xFFFD #x10000-#x10FFFF
    token regascii { <[ \x20..\x7F ]> }
    token nonascii { <- [ \x0..\x7F ]> }
    token escape   { '\\'[ <char=.unicode> || <char=.regascii> | <char=.nonascii> ] }
    token nmstrt   { (<[_ a..z A..Z]>) | <char=.nonascii> | <char=.escape> }
    token nmchar   { <char=.nmreg> | <char=.nonascii> | <char=.escape> }
    token nmreg    { <[_ \- a..z A..Z 0..9]>+ }
    # don't redefine <ident>, it's a built-in
    token Ident    { $<pfx>='-'? <nmstrt> <nmchar>* }
    token name     { <nmchar>+ }
    token num      { < + - >? [\d* \.]? \d+ [:i'e' < + - >?\d+]? }
    token uint     {\d+}
    token op($chr) {$chr}

    token stringchar-regular {<[ \x20 \! \# \$ \% \& \(..\[ \]..\~ ]>+ }
    proto token stringchar {*}
    token stringchar:sym<cont>     { \\ \n }
    token stringchar:sym<escape>   { <escape> }
    token stringchar:sym<nonascii> { <nonascii> }
    token stringchar:sym<ascii>    { <stringchar-regular>+ }

    token single-quote   {\'}
    token double-quote   {\"}
    proto token string   {*}
    token string:sym<double-q>  { \"[ <stringchar> | <stringchar=.single-quote> ]*\" }
    token string:sym<single-q>  { \'[ <stringchar> | <stringchar=.double-quote> ]*\' }

    token id             { '#'<name> }
    token class          { '.'<name> }
    token element-name   { <Ident> }

    proto token length-units     {*}
    token length-units:sym<abs>  {:i pt|mm|cm|pc|in|px|<rel-font-units> }
    token rel-font-units         {:i [em|ex] }
    token rel-font-length        {:i $<sign>=< + - >? <rel-font-units> }

    proto token length           {*}
    token length:sym<dim>        {:i <num><units=.length-units> }
    # As a special case, relative font lengths don't need a number.
    # E.g. -ex :== -1ex
    token length:sym<rel-font-length> { <rel-font-length> }

    proto token dimension {*}
    token dimension:sym<length> { <length> }

    token url-delim-char { < ( ) ' " \\ > | <.wc> }
    token url-unquoted-char  { <char=.escape> | <char=.nonascii> | <- url-delim-char>+ }
    token url-unquoted       {<url-unquoted-char>*}

    rule url             {:i'url(' [ <url=.url-string> | <url=.url-unquoted> ] ')' }
    token url-string     {<string>}

    token percentage     { <num>'%' }

    # productions

    token operator       {< / , = >}

    rule property        { <.ws>? <Ident> ':' }
    rule end-decl        { ';' | <?before '}'> | $ }

    rule color-range     { <num>$<percentage>=[\%]? }

    proto rule color     {*}
    rule color:sym<rgb>  {:i 'rgb('
			      [ <color-range> **3% ',' || <any-args> ]
                                ')'
                         }
    rule color:sym<hex>  { <id> }

    token prio           {:i '!' [ ('important') || <any> ] }

    # pseudos
    proto rule pseudo {*}

    # Combinators - introduced with css2.1
    proto rule combinator {*}
    rule combinator:sym<adjacent> { '+' }
    rule combinator:sym<child>    { '>' }

    token term {<term=.term1>||<term=.term2>}

    proto rule term1  {*}
    rule term1:sym<num>        {<num><!before ['%'|\w]>}
    rule term1:sym<ident>      {[<rel-font-length>|<Ident>]<!before '('>}
    rule term1:sym<percentage> {<percentage>}
    rule term1:sym<string>     {<string>}
    rule term1:sym<color>      {<color>}
    rule term1:sym<url>        {<url>}

    proto rule term2  {*}
    rule term2:sym<dimension>  {<dimension>||<any-dimension>}

    rule any-dimension        {<num>$<units:unknown>=<.Ident>}

    # Unicode ranges - used by selector modules + scan rules
    rule unicode-range         {:i 'U+' [ $<from>=[<.xdigit>**1..6] '-' $<to>=[<.xdigit>**1..6]
                                        ||$<mask>=[<.xdigit>|'?']**1..6 ]}

    # Error Recovery
    # --------------
    # - <any>                    - for unknown terms etc
    rule any       {<CSS::Grammar::Core::_value>}
    # - <any-arg>, <any-args>    - for incorrect function args
    rule any-arg   {<CSS::Grammar::Core::_arg>}
    rule any-args  {<any-arg>*}
    # - <badstring>               - for unclosed strings
    rule badstring {<CSS::Grammar::Core::_badstring>}

    # failed declaration parse - analyse and drop
    rule dropped-decl  {
	       # - extra semicolon - just ignore
	       ';'

	       # - well-formed terms - flush to end of declaration
	       || [ [<property>||<any>] [<expr>||<any>]*? <end-decl> ]

	       # - stop on unterminated string. might consume ';' '}' 
	       || <property>? <any>*? <.badstring> <end-decl>?

	       # - last resort - flush characters
	       || [ <any=.any-arg> || $<any>=<- [\;\}]> ]+? <end-decl>
    }

    rule end-block {[$<closing-paren>='}' ';'?]?}

    # forward compatible scanning and recovery - from the stylesheet top level
    # - skip statements, at-rules or other recognised constructs
    token unknown  {  <CSS::Grammar::Core::_statement>
                   || <CSS::Grammar::Core::_arg>
                   || <CSS::Grammar::Core::_ascii-punct>
                   # - last resort - skip a character
                   || <[.]>+?
                   }
}

grammar CSS::Grammar::Core #api<css2-20110607>
    is CSS::Grammar {

    # Fallback/Normalization Grammar
    # This is based on the core grammar syntax described in
    # http://www.w3.org/TR/2011/REC-CSS2-20110607/syndata.html#syntax
    # It is a scanning grammar that is only used to implement
    # term flushing, for forward compatiblity and error recovery
    #

    # Term Flushing:
    # --------------
    # It's been generalized to handle the rule dropping requirements outlined
    # in http://www.w3.org/TR/2003/WD-css3-syntax-20030813/#rule-sets
    # e.g this should be completely scanned as single statement:
    # h3, h4 & h5 {color: red }

    # Errata:
    # -------
    # - declarations are less structured - optimized for robustness
    # - added <_op> for general purpose operator detection
    # - may assume closing parenthesis in nested values and blocks

    rule TOP           {^ <_stylesheet> $}
    rule _stylesheet   { [<.ws>?<_statement>]* }
    rule _statement    { <_ruleset> | <_at-rule> || <_any> || <_delim> }

    rule _at-rule      {['@'<.Ident>] <_any>* [ <_block> | <_badstring> | ';' ]}
    rule _block        {'{' [ <_value> | <_badstring> | ';' ]* '}'?}

    rule _ruleset      { <!after \@> <_selectors>? <_declarations> }
    rule _selectors    { [<_any> | <_badstring>]+ }
    rule _declarations { '{' <_declaration> *%% ';'? '}'? }
    rule _declaration  { [ <.property> | <_value> | <.badstring> ]+ }
    rule _value        { [ <_any> | <_block> ]+ }

    token _ascii-punct {<[\! .. \~] -alnum>}
    token _delim       {<[ \( \) \[ \] \{ \} \; \" \' \\ ]>}
    token _op          {[<._ascii-punct> & <- _delim>]+}

    token _badstring   {\"[<.stringchar>|\']*[\n|$]
                       |\'[<.stringchar>|\"]*[\n|$]}

    proto rule _any {*}
    rule _any:sym<string> { <.string> }
    rule _any:sym<dim>    { <.num>['%'|<.Ident>]? }
    rule _any:sym<urange> { <.unicode-range> }
    rule _any:sym<ident>  { <.Ident> }
    rule _any:sym<pseudo> { <.pseudo> }
    rule _any:sym<id>     { <.id> }
    rule _any:sym<class>  { <.class> }
    rule _any:sym<at-keyw>{ '@'<.Ident> }
    rule _any:sym<op>     { <._op> }
    rule _any:sym<attrib> { '[' <._arg>* ']'? }
    rule _any:sym<args>   { '(' <._arg>* ')'? }

    rule _arg {[ <_any> | <_block> | <_badstring> ]}
}
