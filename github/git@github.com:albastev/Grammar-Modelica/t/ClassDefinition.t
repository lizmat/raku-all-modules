#!perl6

use v6;
use Test;
use lib '../lib';
use Grammar::Modelica;

plan 121;

# Here we create a subclass to only test the bit we are interested in
grammar TestClassDefinition is Grammar::Modelica {
  # Here we set the bit we want to test to TOP
  rule TOP {^<class_definition>$}
  # Here we replace bits of the regex we are not testing yet with placeholders
  token class_prefixes { <|w>'class_prefixes'<|w> }
  token class_specifier { <|w>'class_specifier'<|w> }
}
ok TestClassDefinition.parse('encapsulated class_prefixes class_specifier');
ok TestClassDefinition.parse('class_prefixes class_specifier');
nok TestClassDefinition.parse('encapsulatedclass_prefixes class_specifier');
nok TestClassDefinition.parse('encapsulated class_prefixesclass_specifier');
ok TestClassDefinition.parse('encapsulated class_prefixes/*comment*/class_specifier');

grammar TestClassPrefixes is Grammar::Modelica {
  rule TOP {^<class_prefixes>$}
}
ok TestClassPrefixes.parse('partial operator');
nok TestClassPrefixes.parse('partialoperator');
ok TestClassPrefixes.parse('operator');
ok TestClassPrefixes.parse('partial class');
nok TestClassPrefixes.parse('partialclass');
ok TestClassPrefixes.parse('class');
ok TestClassPrefixes.parse('partial model');
ok TestClassPrefixes.parse('model');
ok TestClassPrefixes.parse('partial operator record');
nok TestClassPrefixes.parse('partial operatorrecord');
nok TestClassPrefixes.parse('partialoperator record');
ok TestClassPrefixes.parse('partial record');
ok TestClassPrefixes.parse('operator record');
ok TestClassPrefixes.parse('record');
ok TestClassPrefixes.parse('partial block');
ok TestClassPrefixes.parse('block');
ok TestClassPrefixes.parse('partial expandable connector');
ok TestClassPrefixes.parse('partial  expandable connector');
ok TestClassPrefixes.parse('partial expandable/*comment */connector');
nok TestClassPrefixes.parse('partialexpandable connector');
nok TestClassPrefixes.parse('partial expandableconnector');
ok TestClassPrefixes.parse('expandable connector');
ok TestClassPrefixes.parse('partial connector');
ok TestClassPrefixes.parse('connector');
ok TestClassPrefixes.parse('partial type');
ok TestClassPrefixes.parse('type');
ok TestClassPrefixes.parse('partial package');
ok TestClassPrefixes.parse('package');
ok TestClassPrefixes.parse('partial pure operator function');
ok TestClassPrefixes.parse('partial impure operator function');
nok TestClassPrefixes.parse('partial impure operatorfunction');
nok TestClassPrefixes.parse('partial impureoperator function');
nok TestClassPrefixes.parse('partialimpure operator function');
ok TestClassPrefixes.parse('pure operator function');
ok TestClassPrefixes.parse('impure operator function');
ok TestClassPrefixes.parse('partial operator function');
ok TestClassPrefixes.parse('partial pure function');
ok TestClassPrefixes.parse('partial impure function');
ok TestClassPrefixes.parse('partial function');
ok TestClassPrefixes.parse('function');

grammar TestClassDefinition2 is Grammar::Modelica {
  rule TOP {^<class_definition>$}
  token class_specifier { <|w>'class_specifier'<|w> }
}
ok TestClassDefinition2.parse('encapsulated partial operator function class_specifier');
nok TestClassDefinition2.parse('encapsulatedpartial operator function class_specifier');
nok TestClassDefinition2.parse('encapsulatedpartial operator functionclass_specifier');

grammar TestLongClassSpecifier is Grammar::Modelica {
  rule TOP {^<long_class_specifier>$}
  rule composition {<|w>'compostion'<|w>}
  rule class_modification {<|w>'class_modification'<|w>}
}

ok TestLongClassSpecifier.parse('valid_ident "string_comment" compostion end valid_ident');
ok TestLongClassSpecifier.parse('valid_ident/*comment*/"string_comment" compostion end valid_ident');
ok TestLongClassSpecifier.parse('valid_ident "string_comment" compostion end/*comment*/valid_ident');
ok TestLongClassSpecifier.parse('valid_ident "string_comment" compostion/*comment*/end valid_ident');
ok TestLongClassSpecifier.parse('valid_ident"string_comment" compostion end valid_ident');
nok TestLongClassSpecifier.parse('valid_ident "string_comment" compostion endvalid_ident');
nok TestLongClassSpecifier.parse('valid_ident "string_comment" compostion end different_ident');
ok TestLongClassSpecifier.parse('extends valid_ident class_modification "string_comment" compostion end valid_ident');
nok TestLongClassSpecifier.parse('extendsvalid_ident class_modification "string_comment" compostion end valid_ident');
nok TestLongClassSpecifier.parse('extends valid_identclass_modification "string_comment" compostion end valid_ident');

grammar TestShortClassSpecifier is Grammar::Modelica {
  rule TOP {^<short_class_specifier>$}
  token base_prefix {<|w>'base_prefix'<|w>}
  rule array_subscripts {<|w>'array_subscripts'<|w>}
  rule class_modification {<|w>'class_modification'<|w>}
  rule comment {<|w>'comment'<|w>}
  rule enum_list {<|w>'enum_list'<|w>}
}

ok TestShortClassSpecifier.parse('valid_ident = base_prefix valid_name array_subscripts class_modification comment');
ok TestShortClassSpecifier.parse('valid_ident=base_prefix valid_name array_subscripts class_modification comment');
ok TestShortClassSpecifier.parse('valid_ident = base_prefix valid_name comment');
ok TestShortClassSpecifier.parse('valid_ident = enumeration (enum_list) comment');
ok TestShortClassSpecifier.parse('valid_ident = enumeration (:) comment');
ok TestShortClassSpecifier.parse('valid_ident = enumeration () comment');
ok TestShortClassSpecifier.parse('valid_ident =enumeration () comment');
ok TestShortClassSpecifier.parse('valid_ident = enumeration() comment');
ok TestShortClassSpecifier.parse('valid_ident = enumeration ()comment');

grammar TestDerClassSpecifier is Grammar::Modelica {
  rule TOP {^<der_class_specifier>$}
  rule comment {<|w>'comment'<|w>}
}

ok TestDerClassSpecifier.parse('valid_ident = der ( valid_name , valid_ident2 , valid_ident3 ) comment');
ok TestDerClassSpecifier.parse('valid_ident=der(valid_name,valid_ident2,valid_ident3)comment');
nok TestDerClassSpecifier.parse('valid_ident = der  valid_name , valid_ident2 , valid_ident3 ) comment');

grammar TestEnumList is Grammar::Modelica {
  rule TOP {^<enum_list>$}
  rule enumeration_literal {<|w>'enumeration_literal'<|w>}
}

ok TestEnumList.parse('enumeration_literal');
ok TestEnumList.parse('enumeration_literal , enumeration_literal');
ok TestEnumList.parse('enumeration_literal,enumeration_literal');
ok TestEnumList.parse('enumeration_literal , enumeration_literal , enumeration_literal');

grammar TestEnumerationLiteral is Grammar::Modelica {
  rule TOP {^<enumeration_literal>$}
}

ok TestEnumerationLiteral.parse('valid_ident "valid comment"');
ok TestEnumerationLiteral.parse('valid_ident"valid comment"');

grammar TestComposition is Grammar::Modelica {
  rule TOP {^<composition>$}
  rule element_list {'element_list'}
  rule equation_section {'equation_section'}
  rule algorithm_section {'algorithm_section'}
  rule language_specification {'language_specification'}
  rule external_function_call {'external_function_call'}
  rule annotation {'annotation'}
}

ok TestComposition.parse('element_list public element_list protected element_list equation_section algorithm_section external language_specification external_function_call annotation ; annotation ;');
ok TestComposition.parse('element_list');
ok TestComposition.parse('element_list annotation;');
ok TestComposition.parse('element_list equation_section public element_list external;');
ok TestComposition.parse('element_list protected element_list public element_list external;');
nok TestComposition.parse('element_listprotected element_list public element_list external;');
nok TestComposition.parse('element_list protectedelement_list public element_list external;');
nok TestComposition.parse('element_list protected element_listpublic element_list external;');
nok TestComposition.parse('element_list protected element_list publicelement_list external;');
nok TestComposition.parse('element_list protected element_list public element_listexternal;');

grammar TestLanguageSpec is Grammar::Modelica {
  rule TOP {^<language_specification>$}
}

ok TestLanguageSpec.parse('"valid language spec"');
nok TestLanguageSpec.parse('invalid language spec');

grammar TestExternalFuncCall is Grammar::Modelica {
  rule TOP {^<external_function_call>$}
  rule expression_list {'expression_list'}
}

ok TestExternalFuncCall.parse('valid_component_reference = valid_ident ( expression_list )');
ok TestExternalFuncCall.parse('valid_ident ()');
ok TestExternalFuncCall.parse('valid_component_reference=valid_ident(expression_list)');

grammar TestElementList is Grammar::Modelica {
  rule TOP {^<element_list>$}
  rule element {'element'}
}

ok TestElementList.parse('element;');
ok TestElementList.parse('element;element;');
ok TestElementList.parse('element;element;element;');
ok TestElementList.parse('element ; element ; element ;');

grammar TestElement is Grammar::Modelica {
  rule TOP {^<element>$}
  rule import_clause {'import_clause'}
  rule extends_clause {'extends_clause'}
  rule class_definition {'class_definition'}
  rule component_clause {'component_clause'}
  rule constraining_clause {'constraining_clause'}
}

ok TestElement.parse('import_clause');
ok TestElement.parse('extends_clause');
ok TestElement.parse('redeclare final inner outer class_definition');
ok TestElement.parse('redeclare final inner outer component_clause');
nok TestElement.parse('redeclarefinal inner outer component_clause');
nok TestElement.parse('redeclare finalinner outer component_clause');
nok TestElement.parse('redeclare final innerouter component_clause');
ok TestElement.parse('redeclare final inner outer replaceable class_definition constraining_clause "valid comment"');
ok TestElement.parse('redeclare final inner outer replaceable component_clause constraining_clause "valid comment"');

grammar TestImportList is Grammar::Modelica {
  rule TOP {^<import_list>$}
}

ok TestImportList.parse('valid_ident');
ok TestImportList.parse('valid_ident,valid_ident');
ok TestImportList.parse('valid_ident,valid_ident,valid_ident');
ok TestImportList.parse('valid_ident , valid_ident , valid_ident');
nok TestImportList.parse('valid_ident , valid_ident valid_ident');

grammar TestImportClause is Grammar::Modelica {
  rule TOP {^<import_clause>$}
}

ok TestImportClause.parse('import valid_ident = valid_name "valid comment"');
ok TestImportClause.parse('import valid_ident=valid_name"valid comment"');
ok TestImportClause.parse('import valid_name "valid comment"');
ok TestImportClause.parse('import valid_name.* "valid comment"');
ok TestImportClause.parse('import valid_name.{valid_ident} "valid comment"');
ok TestImportClause.parse('import valid_name.{valid_ident,valid_ident,valid_ident} "valid comment"');
ok TestImportClause.parse('import valid_name.{ valid_ident,valid_ident,valid_ident } "valid comment"');
ok TestImportClause.parse('import valid_name.{valid_ident,valid_ident,valid_ident}"valid comment"');
nok TestImportClause.parse('importvalid_name.{valid_ident,valid_ident,valid_ident} "valid comment"');
nok TestImportClause.parse('import valid_name.valid_ident,valid_ident,valid_ident} "valid comment"');
nok TestImportClause.parse('import valid_name.{valid_ident,valid_ident,valid_ident "valid comment"');
nok TestImportClause.parse('import valid_name{valid_ident,valid_ident,valid_ident} "valid comment"');
