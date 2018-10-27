use v6;

use CSS::Grammar;
# specification: http://www.w3.org/TR/2008/REC-CSS1-20080411/

grammar CSS::Grammar::CSS1 #:api<css1-20080411>
    is CSS::Grammar {

    rule TOP {^ <stylesheet> $}

    # productions

    rule stylesheet { <.ws> <import>* [<ruleset> || <misplaced> || <unknown>]* }

    rule import { '@'(:i'import') [<url-string>|<url>] ';' }

    # to detect out of order directives
    rule misplaced {<import>}

    rule ruleset {
        <!after '@'> # not an "@" rule
        <selectors> <declarations>
    }

    rule selectors { <selector> +% ',' }

    rule declarations {
        '{' <declaration-list> <.end-block>
    }

    # this rule is suitable for parsing style attributes in HTML documents.
    # see: http://www.w3.org/TR/2010/CR-css-style-attr-20101012/#syntax
    #
    rule declaration-list { <declaration> * }
    rule declaration      { <any-declaration> }
    rule any-declaration  { <Ident=.property> <expr> <prio>? <end-decl> || <dropped-decl> }
    # css1 syntax allows a unary operator in front of all terms. Throw it
    # out, if the term doesn't consume it.
    rule expr { [<term>||<.unary-op><term>] +% [ <term=.operator>? ] }
    rule unary-op       {< + - >}

    token selector {<simple-selector> +% <.ws> <pseudo>?}
    # <qname> - for forward compat with css2.1 and 3
    # - see http://www.w3.org/TR/2008/CR-css3-namespace-20080523/#css-qnames
    token qname           { <element-name> }
    token simple-selector { <qname> <id>? <class>? <pseudo>?
                          | <id> <class>? <pseudo>?
                          | <class> <pseudo>?
                          | <pseudo> }

    rule pseudo:sym<:element> {':'$<element>=[:i'first-'[line|letter]]}
    # assume anything else is a class
    rule pseudo:sym<class>   {':' <class=.Ident> }

    # 'lexer' css1 exceptions:
    # -- css1 identifiers - don't allow '_' or leading '-'
    token nmstrt   {(<[a..z A..Z]>)|<nonascii>|<escape>}
    token nmreg    {<[\- a..z A..Z 0..9]>+}
    token Ident    {<nmstrt><nmchar>*}
    # -- css1 unicode escape sequences only extend to 4 chars and do not consume trailing white-space
    rule unicode   {(<[0..9 a..f A..F]>**1..4)}
    # -- css1 extended characters limited to latin1
    token nonascii {<[\o241..\o377]>}
}
