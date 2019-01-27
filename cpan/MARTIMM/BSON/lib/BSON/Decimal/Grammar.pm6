use v6;

#-------------------------------------------------------------------------------
unit package Decimal:auth<github:MARTIM>;

use Decimal;

#-------------------------------------------------------------------------------
#`{{
  Grammar taken from https://github.com/mongodb/specifications/blob/master/source/bson-decimal128/decimal128.rst

  sign           ::=  ’+’ | ’-’
  digit          ::=  ’0’ | ’1’ | ’2’ | ’3’ | ’4’ | ’5’ | ’6’ | ’7’ |
  ’8’ | ’9’
  indicator      ::=  ’e’ | ’E’
  digits         ::=  digit [digit]...
  decimal-part   ::=  digits ’.’ [digits] | [’.’] digits
  exponent-part  ::=  indicator [sign] digits
  infinity       ::=  ’Infinity’ | ’Inf’
  nan            ::=  ’NaN’
  numeric-value  ::=  decimal-part [exponent-part] | infinity
  numeric-string ::=  [sign] numeric-value | [sign] nan
}}

grammar Grammar {
  rule dxxx { <.initialize> <numeric-string> }
  rule initialize { <?> }

  token sign { <[+-]> }
  token indicator { <[eE]> }
  token digits { \d+ }
  token decimal-part {
    $<characteristic>=<.digits> '.' $<mantissa>=<.digits>? ||
    '.' $<mantissa>=<.digits> ||
    $<characteristic>=<.digits>
  }

  token exponent-part { <.indicator> <sign>? $<exponent>=<.digits> }
  token infinity { 'Infinity' || 'Inf' }
  token nan { 'NaN' }
  token numeric-value { <decimal-part> <exponent-part>? || <infinity> }
  token numeric-string { <sign>? <numeric-value> | <sign>? <nan> }
}
