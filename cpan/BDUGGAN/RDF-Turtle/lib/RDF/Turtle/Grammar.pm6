#!/usr/bin/env perl6

use RDF::Turtle::Error;

# See https://www.w3.org/TeamSubmission/turtle/#sec-grammar-grammar
grammar RDF::Turtle::Grammar {
    has $.quiet;
    has $!error;

    # [1] turtleDoc ::= statement*
    regex TOP {:s [ <statement> | <.comment> ]* }

    # [2] statement ::= directive '.' | triples '.' | ws+
    regex statement {
        | <directive> '.'
        | <triples> '.'
    }

    # [3] directive ::= prefixID | base
    token directive {
        <prefixID> | <base>
    }

    # [4] prefixID ::= '@prefix' ws+ prefixName? ':' uriref
    rule prefixID {
        '@prefix' <prefixName>? ':' <uriref>
    }

    # [5] base ::= '@base' ws+ uriref
    rule base {
       '@base' <uriref>
    }

    # [6] triples ::= subject predicateObjectList
    regex triples { :s
        <subject> <predicateObjectList>
    }

    # [7] predicateObjectList ::= verb objectList ( ';' verb objectList )* ( ';')?
    regex predicateObjectList { :s
        [ <verb> <objectList> ]+ %% ';'
    }

    # [8] objectList ::= object ( ',' object)*
    regex objectList { :s
        <object>+ %% [ ',' | ' ' ]
    }

    # [9] verb ::= predicate | 'a'
    token verb {
        <predicate> || 'a'
    }

    # [11] subject ::= resource | blank
    token subject {
        <resource> | <blank>
    }

    # [12] predicate ::= resource
    token predicate {
        <resource>
    }

    # [13] object ::= resource | blank | literal
    regex object {
        <resource> | <blank> | <literal>
    }

    # [14] literal ::= quotedString ( '@' language )? | datatypeString | integer | double | decimal | boolean
    regex literal {
        || <quotedString> [ '@' <language> ]?
        || <datatypeString>
        || <integer>
        || <double>
        || <decimal>
        || <boolean>
    }

    # [29]    language    ::=    [a-z]+ ('-' [a-z0-9]+ )*
    token language {
        <[a..z]>+ [ '-' <[a..z0..9]>+ ]*
    }

    # [15]    datatypeString    ::=    quotedString '^^' resource
    token datatypeString {
        <quotedString> '^^' <resource>
    }
    
    # [16]    integer     ::=    ('-' | '+') ? [0-9]+
    token integer {
       ['-' | '+']? <[0..9]>+
    }

    # [17]    double      ::=    ('-' | '+') ? ( [0-9]+ '.' [0-9]* exponent | '.' ([0-9])+ exponent | ([0-9])+ exponent )
    token double {
        ['-' | '+']?
        [ <[0..9]>+ '.' <[0..9]>* <exponent>
          | '.' (<[0..9]>)+ <exponent>
          |     (<[0..9]>)+ <exponent> ]
    }

    # [18]    decimal     ::=    ('-' | '+')? ( [0-9]+ '.' [0-9]* | '.' ([0-9])+ | ([0-9])+ )
    token decimal {
        ['-' | '+']?
        [ | <[0..9]>+ '.' <[0..9]>*
          | '.' (<[0..9]>)+
          | (<[0..9]>)+ ]
    }

    # [19]    exponent    ::=    [eE] ('-' | '+')? [0-9]+
    token exponent {
        <[eE]> ['-' | '+']? <[0..9]>+
    }

    # [20]    boolean     ::=    'true' | 'false'
    token boolean {
        'true' | 'false'
    }

    # [21] blank ::= nodeID | '[]' | '[' predicateObjectList ']' | collection
    rule blank {
        | '[]'
        | '[' <predicateObjectList> ']'
        | <collection>
        | <nodeID>
    }

    # [22]    itemList    ::=    object+
    rule itemList {
        <object>+ % ' '
    }

    # [23]    collection  ::=    '(' itemList? ')'
    rule collection {
        '(' ~ ')' <itemList>?
    }
    
    # [25] resource ::= uriref | qname
    rule resource { :!s
        <uriref> | <qname>
    }

    # [26]    nodeID      ::=    '_:' name
    token nodeID {
        '_:' <name>
    }

    # [27] qname ::= prefixName? ':' name?
    token qname {
        <prefixName>? ':' <name>?
    }

    # [33] prefixName ::= ( nameStartChar - '_' ) nameChar*
    token prefixName {
        [ <.nameStartChar> & <-[_]> ] <.nameChar>*
    }

    # [32] name ::= nameStartChar nameChar*
    token name {
        <.nameStartChar> <.nameChar>*
    }

    # [31] nameChar ::= nameStartChar | '-' | [0-9] | #x00B7 | [#x0300-#x036F] | [#x203F-#x2040]
    token nameChar {
        | <.nameStartChar>
        | '-'
        | <[0..9]>
        | \c[0x00B7]
        | <[\c[0x0300]..\c[0x036F]]>
        | <[\c[0x203F]..\c[0x2040]]>
    }

    # [30] nameStartChar ::= 
    #         [A-Z] | "_" | [a-z] | [#x00C0-#x00D6]
    #         | [#x00D8-#x00F6] | [#x00F8-#x02FF]
    #         | [#x0370-#x037D] | [#x037F-#x1FFF]
    #         | [#x200C-#x200D] | [#x2070-#x218F]
    #         | [#x2C00-#x2FEF] | [#x3001-#xD7FF]
    #         | [#xF900-#xFDCF] | [#xFDF0-#xFFFD]
    #         | [#x10000-#xEFFFF]
    token nameStartChar {
        <[A..Z]> | '_' | <[a..z]>
        | <[\c[0x00C0]..\c[0x00D6]]>
        | <[\c[0x00D8]..\c[0x00F6]]> | <[\c[0x00F8]..\c[0x02FF]]>
        | <[\c[0x0370]..\c[0x037D]]> | <[\c[0x037F]..\c[0x1FFF]]>
        | <[\c[0x200C]..\c[0x200D]]> | <[\c[0x2070]..\c[0x218F]]>
        | <[\c[0x2C00]..\c[0x2FEF]]> | <[\c[0x3001]..\c[0xD7FF]]>
        | <[\c[0xF900]..\c[0xFDCF]]> | <[\c[0xFDF0]..\c[0xFFFD]]>
        | <[\c[0x10000]..\c[0xEFFFF]]>
    }

    # [28] uriref ::= '<' relativeURI '>'
    rule uriref {
        '<'<relativeURI>'>'
    }

    # [34] relativeURI ::= ucharacter*
    rule relativeURI {
        <.ucharacter>*
    }

    # [35] quotedString ::= string | longString
    token quotedString {
        <longString> || <string>
    }

    # [37]    longString  ::=    #x22 #x22 #x22 lcharacter* #x22 #x22 #x22
    regex longString { 
        '"""' <lcharacter>* '"""'
    }
 
    # [36] string ::= #x22 scharacter* #x22
    token string {
        '"' <.scharacter>* '"'
    }

    # [41] ucharacter ::= ( character - #x3E ) | '\>'
    token ucharacter  {
        || '\u' <hex> ** 4
        || '\U' <hex> ** 8
        || '\\'
        || '\>'
        || <[\c[0x20]..\c[0x5B]] - [>]>
        || <[\c[0x5D]..\c[0x10FFFF]]>
    }

    # [42] scharacter    ::=    ( echaracter - #x22 ) | '\"'
    token scharacter {
        | <.echaracter> & <-["]>
        | '\"'
    }

    # [43]    lcharacter  ::=    echaracter | '\"' | #x9 | #xA | #xD
    token lcharacter {
        <.echaracter>
        | '\"' | "\r" | "\n" | "\t"
    }

    # [38] character  ::=  '\u' hex hex hex hex
    #                       | '\U' hex hex hex hex hex hex hex hex
    #                       | '\\'
    #                       | [#x20-#x5B]
    #                       | [#x5D-#x10FFFF]
    token character  {
        || '\u' <hex> ** 4
        || '\U' <hex> ** 8
        || '\\\\'
        || <[\c[0x20]..\c[0x5B]]>
        || <[\c[0x5D]..\c[0x10FFFF]]>
    }

    # [39] echaracter ::= character | '\t' | '\n' | '\r'
    token echaracter {
        | <character>
        | '\t' | '\n' | '\r'
    }

    # [40] hex ::= [#x30-#x39] | [#x41-#x46]
    token hex { <[0..9] + [A..F]> }

    # [24] ws ::= #x9 | #xA | #xD | #x20 | comment
    # See method ws below, for error handling.
    token customws {
        [ \c[0x09] | \c[0x0A] | \c[0x0D] | \c[0x20] | <comment> ]*
    }

    # [10] comment    ::=    '#' ( [^#xA#xD] )*
    token comment {
        '#' \V+ \n
    }

    multi method error($msg) {
        self.error(self.target,$msg);
    }

    multi method error($target,$msg) {
        my $parsed = $target.substr(0, $*HIGHWATER).trim-trailing;
        $!error = RDF::Turtle::Error.new(:$parsed,:$target);
        $!error.report($msg) unless $.quiet;
    }

    method parse-error {
        $!error;
    }

    method ws() {
        if self.pos > $*HIGHWATER {
            $*HIGHWATER = self.pos;
            $*LASTRULE = callframe(1).code.name;
        }
        self.customws;
    }

    method parse($target, |c) {
        my $*HIGHWATER = 0;
        my $*LASTRULE;
        my $match = callsame;
        self.error($target, "Could not parse turtle.") unless $match;
        return $match;
    }
}
