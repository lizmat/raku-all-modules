use v6;

use CSS::Grammar::CSS21;

# specification: http://www.w3.org/TR/2003/WD-css3-syntax-20030813/

grammar CSS::Grammar::CSS3:ver<20030813.000>
    is CSS::Grammar::CSS21;

rule TOP {^ <stylesheet> $}

# productions
rule stylesheet { <.ws> <charset>? [ <import> ]* [ <at-rule=.at-decl> ]*
		  [ <at-rule> | <ruleset> || <misplaced> || <unknown> ]* }
# <at-decl> - at rules preceding main body - aka @namespace extensions
proto rule at-decl {*}

# allow '::' element selectors
rule pseudo:sym<::element> {'::'<element=.Ident>}
 
# to detect out of order directives
rule misplaced     {<charset>|<import>|<at-decl>}

# 'lexer' css3 exceptions
token nonascii     {<- [\x0..\x7F]>}

