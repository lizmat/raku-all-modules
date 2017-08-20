#!perl6

use v6;

unit role Grammar::Modelica::Modification;

rule modification {
  [<class_modification> ['=' <expression>]?] ||
  [':=' <expression>] ||
  ['=' <expression>]
}

rule class_modification {
  '(' <argument_list>? ')'
}

rule argument_list {
  <argument> [ ',' <argument> ]*
}

token argument {<element_modification_or_replaceable>||<element_redeclaration>}

rule element_modification_or_replaceable {
  [<|w>'each'<|w>]? [<|w>'final'<|w>]? [<element_modification> || <element_replaceable>]
}

rule element_modification {
  <name> <modification>? <string_comment>
}

rule element_redeclaration {
  <|w>'redeclare'<|w> [<|w>'each'<|w>]? [<|w>'final'<|w>]?
  [ [ <short_class_definition> || <component_clause1>] || <element_replaceable> ]
}

rule element_replaceable {
  <|w>'replaceable'<|w> [<short_class_definition> || <component_clause1>]
  <constraining_clause>?
}

rule component_clause1 {
  <type_prefix> <type_specifier> <component_declaration1>
}

rule component_declaration1 {
  <declaration> <comment>
}

rule short_class_definition {
  <class_prefixes> <short_class_specifier>
}
