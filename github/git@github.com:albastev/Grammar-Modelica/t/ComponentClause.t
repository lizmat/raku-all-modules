#!perl6

use v6;
use Test;
use lib '../lib';
use Grammar::Modelica;

plan 34;

# Here we create a subclass to only test the bit we are interested in
grammar TestTypePrefix is Grammar::Modelica {
  # Here we set the bit we want to test to TOP
  rule TOP {^<type_prefix>$}
}
ok TestTypePrefix.parse('flow discrete input');
ok TestTypePrefix.parse('flow discrete output');
ok TestTypePrefix.parse('flow parameter input');
ok TestTypePrefix.parse('flow parameter output');
ok TestTypePrefix.parse('flow constant input');
ok TestTypePrefix.parse('flow constant output');
ok TestTypePrefix.parse('stream discrete input');
ok TestTypePrefix.parse('stream discrete output');
ok TestTypePrefix.parse('stream parameter input');
ok TestTypePrefix.parse('stream parameter output');
ok TestTypePrefix.parse('stream constant input');
ok TestTypePrefix.parse('stream constant output');
ok TestTypePrefix.parse('output');
ok TestTypePrefix.parse('constant');
ok TestTypePrefix.parse('stream constant');
ok TestTypePrefix.parse('stream output');
ok TestTypePrefix.parse('');
nok TestTypePrefix.parse('output stream');
nok TestTypePrefix.parse('streamparameter output');
nok TestTypePrefix.parse('stream parameteroutput');

# Here we create a subclass to only test the bit we are interested in
grammar TestComponentClause is Grammar::Modelica {
  # Here we set the bit we want to test to TOP
  rule TOP {^<component_clause>$}
  # Here we replace bits of the regex we are not testing yet with placeholders
  token array_subscripts { <|w>'array_subscripts'<|w> }
  token component_list { <|w>'component_list'<|w> }
}
ok TestComponentClause.parse('stream output valid_type_specifier array_subscripts component_list');
ok TestComponentClause.parse('stream output valid_type_specifier component_list');
nok TestComponentClause.parse('stream output valid_type_specifier');
ok TestComponentClause.parse('valid_type_specifier array_subscripts component_list');
ok TestComponentClause.parse('valid_type_specifier component_list');
ok TestComponentClause.parse('.valid.type_specifier.this_is component_list');

grammar TestComponentList is Grammar::Modelica {
  rule TOP {^<component_list>$}
  token component_declaration {'component_declaration'}
}
ok TestComponentList.parse('component_declaration');
ok TestComponentList.parse('component_declaration,component_declaration');
ok TestComponentList.parse('component_declaration,component_declaration,component_declaration');
ok TestComponentList.parse('component_declaration ,component_declaration, component_declaration , component_declaration');
nok TestComponentList.parse('component_declaration,component_declaration component_declaration');

grammar TestComponentDeclaration is Grammar::Modelica {
  rule TOP {^<component_declaration>$}
  token condition_attribute {'condition_attribute'}
}
ok TestComponentDeclaration.parse('valid_declaration condition_attribute "valid comment"');
ok TestComponentDeclaration.parse('valid_declaration "valid comment"');
ok TestComponentDeclaration.parse('valid_declaration"valid comment"');
