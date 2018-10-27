#!perl6

use v6;
use Test;
use lib '../lib';
use Grammar::Modelica;

plan 9;

say 'Test extends_clause';
# Here we create a subclass to only test the bit we are interested in
grammar TestExtendsClause is Grammar::Modelica {
  # Here we set the bit we want to test to TOP
  rule TOP {^<extends_clause>$}
  # Here we replace bits of the regex we are not testing yet with placeholders
  token class_modification { <|w>'class_modification'<|w> }
  token annotation { <|w>'annotation'<|w> }
}

ok TestExtendsClause.parse('extends valid_name class_modification annotation');
ok TestExtendsClause.parse('extends valid_name annotation');
ok TestExtendsClause.parse('extends valid_name class_modification');
ok TestExtendsClause.parse('extends valid_name');
nok TestExtendsClause.parse('extendsvalid_name');

say 'Test constraining_clause';
grammar TestConstrainingClause is Grammar::Modelica {
  rule TOP {^<constraining_clause>$}
  token class_modification { <|w>'class_modification'<|w> }
}
ok TestConstrainingClause.parse('constrainedby valid_name class_modification');
ok TestConstrainingClause.parse('constrainedby valid_name');
nok TestConstrainingClause.parse('constrainedby');
nok TestConstrainingClause.parse('constrainedbyvalid_name class_modification');
