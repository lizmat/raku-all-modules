#!perl6

use v6;

unit role Grammar::Modelica::LexicalConventions;

token BASEIDENT {[[<|w><NONDIGIT>[<DIGIT>||<NONDIGIT>]*]<|w>||<Q-IDENT>]<!after <|w><keywords>>}

token Q-IDENT {<[']>[<Q-CHAR>||<S-ESCAPE>]+<[']>}

regex NONDIGIT { <[A..Za..z_]> }

regex STRING { '"' [ <S-CHAR> || <S-ESCAPE> ]* '"'}

token S-CHAR {<[ \x[0000] .. \x[10FFFF] ] - [ " \\ ]>}

token Q-CHAR {<NONDIGIT>||<DIGIT>||<[!$%&()*+,./:;<>=?@[\]^{}~#|-]>||" "}

regex S-ESCAPE {'\\\'' || '\\"' || '\\?' || '\\\\' ||
           '\\a' || '\\b' || '\\f' || '\\n' || '\\r' || '\\t' || '\\v'  }

regex DIGIT { <[0..9]> }

#UNSIGNED_INTEGER = DIGIT { DIGIT }
regex UNSIGNED_INTEGER {<DIGIT>+}

#UNSIGNED_NUMBER = UNSIGNED_INTEGER [ "." [ UNSIGNED_INTEGER ] ]
#  [ ( "e" | "E" ) [ "+" | "-" ] UNSIGNED_INTEGER ]
regex UNSIGNED_NUMBER {<UNSIGNED_INTEGER>+['.'<UNSIGNED_INTEGER>?]?[<[eE]><[+-]>?<UNSIGNED_INTEGER>]?}

regex c-comment {['//'.*?$$]||['/*'.*?'*/']}

token ws { [\s|<c-comment>]* }

rule keywords {
  <|w>[ 'within'
   | 'final'
   | 'encapsulated'
   | 'partial'
   | 'class'
   | 'model'
   | 'operator'
   | 'record'
   | 'block'
   | 'expandable'
   | 'connector'
   | 'type'
   | 'package'
   | 'pure'
   | 'impure'
   | 'operator'
   | 'function'
   | 'end'
   | 'extends'
   | 'enumeration'
   | 'der'
   | 'public'
   | 'protected'
   | 'external'
   | 'redeclare'
   | 'final'
   | 'inner'
   | 'outer'
   | 'replaceable'
   | 'import'
   | 'constrainedby'
   | 'flow'
   | 'stream'
   | 'discrete'
   | 'parameter'
   | 'constant'
   | 'input'
   | 'output'
   | 'if'
   | 'each'
   | 'initial'
   | 'equation'
   | 'algorithm'
   | 'break'
   | 'return'
   | 'then'
   | 'elseif'
   | 'else'
   | 'end'
   | 'for'
   | 'loop'
   | 'in'
   | 'while'
   | 'elsewhen'
   | 'connect'
   | 'or'
   | 'and'
   | 'not'
   | 'false'
   | 'true'
   | 'annotation' ]<|w>
}

token IDENT {<!keywords><BASEIDENT>}
