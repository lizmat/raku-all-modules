#!perl6

use v6;
use Test;
use lib '../lib';
use Grammar::Modelica;

# Expression: if (asc2 and v<1) then 0.5/t1 else 0
plan 15;

# Here we create a subclass to only test the bit we are interested in
grammar TestExpression is Grammar::Modelica {
  # Here we set the bit we want to test to TOP
  rule TOP {^<expression>$}
}

ok TestExpression.parse('if asc2 and v<1 then 0.5/t1 else 0');
ok  TestExpression.parse('if (asc2 and v<1) then 0.5/t1 else 0');

# Here we create a subclass to only test the bit we are interested in
grammar TestPrimary is Grammar::Modelica {
  # Here we set the bit we want to test to TOP
  rule TOP {^<primary>$}
}

ok  TestPrimary.parse('(asc2 and v<1) ');

# Here we create a subclass to only test the bit we are interested in
grammar TestFactor is Grammar::Modelica {
  # Here we set the bit we want to test to TOP
  rule TOP {^<factor>$}
}

ok  TestFactor.parse('(asc2 and v<1) ');

# Here we create a subclass to only test the bit we are interested in
grammar TestTerm is Grammar::Modelica {
  # Here we set the bit we want to test to TOP
  rule TOP {^<term>$}
}

ok  TestTerm.parse('(asc2 and v<1) ');

# Here we create a subclass to only test the bit we are interested in
grammar TestArithExp is Grammar::Modelica {
  # Here we set the bit we want to test to TOP
  rule TOP {^<arithmetic_expression>$}
}

ok  TestArithExp.parse('(asc2 and v<1) ');

# Here we create a subclass to only test the bit we are interested in
grammar TestRelation is Grammar::Modelica {
  # Here we set the bit we want to test to TOP
  rule TOP {^<relation>$}
}

ok  TestRelation.parse('(asc2 and v<1) ');

# Here we create a subclass to only test the bit we are interested in
grammar TestLogFact is Grammar::Modelica {
  # Here we set the bit we want to test to TOP
  rule TOP {^<logical_factor>$}
}

ok  TestLogFact.parse('(asc2 and v<1) ');

# Here we create a subclass to only test the bit we are interested in
grammar TestLogTerm is Grammar::Modelica {
  # Here we set the bit we want to test to TOP
  rule TOP {^<logical_term>$}
}

ok  TestLogTerm.parse('(asc2 and v<1) ');

# Here we create a subclass to only test the bit we are interested in
grammar TestLogExp is Grammar::Modelica {
  # Here we set the bit we want to test to TOP
  rule TOP {^<logical_expression>$}
}

ok  TestLogExp.parse('(asc2 and v<1) ');

# Here we create a subclass to only test the bit we are interested in
grammar TestSimpleExp is Grammar::Modelica {
  # Here we set the bit we want to test to TOP
  rule TOP {^<simple_expression>$}
}

ok  TestSimpleExp.parse('(asc2 and v<1) ');

# Here we create a subclass to only test the bit we are interested in
grammar TestExp is Grammar::Modelica {
  # Here we set the bit we want to test to TOP
  rule TOP {^<expression>$}
}

ok  TestExp.parse('(asc2 and v<1)');
ok  TestExp.parse('if(asc2 and v<1) then 1 else 0');
ok  TestExp.parse('if(asc2 and v<1)then 1 else 0');
ok  TestExp.parse('if (asc2 and v<1)then 1 else 0');
