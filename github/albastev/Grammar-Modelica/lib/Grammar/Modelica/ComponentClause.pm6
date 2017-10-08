#!perl6

use v6;

unit role Grammar::Modelica::ComponentClause;

rule component_clause {
  <type_prefix> <type_specifier> <array_subscripts>? <component_list>
}

rule type_prefix {
  [<|w>[ 'flow' || 'stream' ]<|w>]?
  [<|w>[ 'discrete' || 'parameter' || 'constant' ]<|w>]? [<|w>[ 'input' || 'output' ]<|w>]?
}

rule component_list {
  <component_declaration> [ ',' <component_declaration> ]*
}

rule component_declaration {
  <declaration> <condition_attribute>? <comment>
}

rule condition_attribute { 'if' <expression> }

rule declaration {
  <IDENT> <array_subscripts>? <modification>?
}
