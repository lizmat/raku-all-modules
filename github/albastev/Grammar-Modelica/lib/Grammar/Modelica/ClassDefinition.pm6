#!perl6

use v6;

unit role Grammar::Modelica::ClassDefinition;

rule class_definition { [<|w>$<encapsulated>='encapsulated'<|w>]? <class_prefixes> <class_specifier> }

rule class_prefixes { $<partial>=(<|w>'partial'<|w>)? <|w>( 'class' || 'model' || [ 'operator'? <|w>'record' ] ||
  'block' || [ 'expandable'? <|w>'connector'] || 'type' || 'package' || [[ 'pure' | 'impure' ]? [<|w>'operator'?] <|w>'function'] ||
  'operator'
) <!ww> }

token class_specifier {<long_class_specifier>||<short_class_specifier>||<der_class_specifier>}

rule long_class_specifier {
  [(<IDENT>) <string_comment> <composition> <|w>'end'<|w> $0 ]
  ||
  [<|w>'extends'<|w> (<IDENT>) <class_modification>? <string_comment> <composition> <|w>'end'<|w> $0 ]
}

rule short_class_specifier {
  [<IDENT> '=' <base_prefix> <type_specifier> <array_subscripts>? <class_modification>? <comment>] ||
  [<IDENT> '=' 'enumeration' '(' [<enum_list>? || ':'] ')' <comment>]
}

rule der_class_specifier {
  <IDENT> '=' 'der' '(' <type_specifier> ',' <IDENT> [ ',' <IDENT> ]* ')' <comment>
}

token base_prefix {<type_prefix>}

rule enum_list {
  <enumeration_literal> [ ',' <enumeration_literal> ]*
}

rule enumeration_literal {
  <IDENT> <comment>
}

rule composition {
  <element_list>
  [
  [<|w>'public'<|w> <element_list>] ||
  [<|w>'protected'<|w> <element_list>] ||
  <equation_section> ||
  <algorithm_section>
  ]*
  [
  <|w>'external'<|w> <language_specification>? <external_function_call>? <annotation>? ';'
  ]? # optional
  [<annotation> ';']? #optional
}

token language_specification {<STRING>}

rule external_function_call {
  [<component_reference> '=']?
  <IDENT> '(' <expression_list>? ')'
}

rule element_list {
  [ <element> ';' ]*
}

rule element {
  <import_clause> ||
  <extends_clause> ||
  [<|w>'redeclare'<|w>]? [<|w>'final'<|w>]? [<|w>'inner'<|w>]? [<|w>'outer'<|w>]?
  [
    [<class_definition> || <component_clause>] ||
    <|w>'replaceable'<|w> [<class_definition> || <component_clause>]
    [<constraining_clause> <comment>]?
  ]
}

rule import_clause {
  <|w>'import'<|w>
  [
  [ <IDENT> '=' <name>] || <name> [ '.'[ '*' || [ '{' <import_list> '}' ] ] ]?
  ]
  <comment>
}

rule import_list { <IDENT> [ ',' <IDENT> ]* }
