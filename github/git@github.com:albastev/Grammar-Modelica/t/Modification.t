#!perl6

use v6;
use Test;
use lib '../lib';
use Grammar::Modelica;

plan 49;

# Here we create a subclass to only test the bit we are interested in
grammar TestModification is Grammar::Modelica {
  # Here we set the bit we want to test to TOP
  rule TOP {^<modification>$}
  # Here we replace bits of the regex we are not testing yet with placeholders
  token class_modification { <|w>'class_modification'<|w> }
  token expression { <|w>'expression'<|w> }
}
ok TestModification.parse('class_modification = expression');
ok TestModification.parse('= expression');
ok TestModification.parse(':= expression');

grammar TestClassModification is Grammar::Modelica {
  rule TOP {^<class_modification>$}
  token argument_list {'argument_list'}
}
ok TestClassModification.parse('(argument_list)');
ok TestClassModification.parse('( argument_list )');
ok TestClassModification.parse('()');
ok TestClassModification.parse('( )');

grammar TestArgumentList is Grammar::Modelica {
  rule TOP {^<argument_list>$}
  token argument {'argument'}
}

ok TestArgumentList.parse('argument');
ok TestArgumentList.parse('argument,argument');
ok TestArgumentList.parse('argument,argument,argument');
ok TestArgumentList.parse('argument ,argument, argument , argument');

grammar TestArgument is Grammar::Modelica {
  rule TOP {^<argument>$}
  rule element_modification_or_replaceable {'element_modification_or_replaceable'}
  rule element_redeclaration {'element_redeclaration'}
}
ok TestArgument.parse('element_modification_or_replaceable');
ok TestArgument.parse('element_redeclaration');

grammar TestElementModOrRep is Grammar::Modelica {
  rule TOP {^<element_modification_or_replaceable>$}
  rule element_modification {'element_modification'}
  rule element_replaceable {'element_replaceable'}
}

ok TestElementModOrRep.parse('each final element_modification');
ok TestElementModOrRep.parse('each final element_replaceable');
ok TestElementModOrRep.parse('each element_modification');
ok TestElementModOrRep.parse('final element_replaceable');
ok TestElementModOrRep.parse('element_modification');
ok TestElementModOrRep.parse('element_replaceable');
nok TestElementModOrRep.parse('eachfinal element_modification');
nok TestElementModOrRep.parse('each finalelement_replaceable');

grammar TestElementModification is Grammar::Modelica {
  rule TOP {^<element_modification>$}
  rule modification {'modification'}
}

ok TestElementModification.parse('valid_name modification "valid comment"');
ok TestElementModification.parse('valid_name "valid comment"');
ok TestElementModification.parse('valid_name');

grammar TestElementRedeclaration is Grammar::Modelica {
  rule TOP {^<element_redeclaration>$}
  token short_class_definition {'short_class_definition'}
  token component_clause1 {'component_clause1'}
  token element_replaceable {'element_replaceable'}
}
ok TestElementRedeclaration.parse('redeclare each final short_class_definition');
ok TestElementRedeclaration.parse('redeclare each final component_clause1');
ok TestElementRedeclaration.parse('redeclare each final element_replaceable');
ok TestElementRedeclaration.parse('redeclare final short_class_definition');
ok TestElementRedeclaration.parse('redeclare each short_class_definition');
ok TestElementRedeclaration.parse('redeclare short_class_definition');
nok TestElementRedeclaration.parse('redeclareeach final short_class_definition');
nok TestElementRedeclaration.parse('redeclare eachfinal short_class_definition');
nok TestElementRedeclaration.parse('redeclare each finalshort_class_definition');
nok TestElementRedeclaration.parse('each final short_class_definition');
nok TestElementRedeclaration.parse('redeclare each final');

grammar TestElementReplaceable is Grammar::Modelica {
  rule TOP {^<element_replaceable>$}
  token short_class_definition {'short_class_definition'}
  token component_clause1 {'component_clause1'}
  token constraining_clause {'constraining_clause'}
}
ok TestElementReplaceable.parse('replaceable short_class_definition constraining_clause');
ok TestElementReplaceable.parse('replaceable component_clause1 constraining_clause');
ok TestElementReplaceable.parse('replaceable short_class_definition');
ok TestElementReplaceable.parse('replaceable component_clause1');

grammar TestComponentClause1 is Grammar::Modelica {
  rule TOP {^<component_clause1>$}
  token type_prefix {'type_prefix'}
  token component_declaration1 {'component_declaration1'}
}
ok TestComponentClause1.parse('type_prefix valid_type_specifier component_declaration1');
nok TestComponentClause1.parse('valid_type_specifier component_declaration1');
nok TestComponentClause1.parse('type_prefix component_declaration1');
nok TestComponentClause1.parse('type_prefix valid_type_specifier');

grammar TestComponentDeclaration1 is Grammar::Modelica {
  rule TOP {^<component_declaration1>$}
}
ok TestComponentDeclaration1.parse('valid_declaration "valid comment"');
ok TestComponentDeclaration1.parse('valid_declaration');
nok TestComponentDeclaration1.parse('"valid comment"');

grammar TestShortClassDefinition is Grammar::Modelica {
  rule TOP {^<short_class_definition>$}
  rule class_prefixes {'class_prefixes'}
  rule short_class_specifier {'short_class_specifier'}
}
ok TestShortClassDefinition.parse('class_prefixes short_class_specifier');
nok TestShortClassDefinition.parse('short_class_specifier');
nok TestShortClassDefinition.parse('class_prefixes');
