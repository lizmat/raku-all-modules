#!perl6

use v6;
use Test;
use lib '../lib';
use Grammar::Modelica;

plan 15;

grammar TestWithin is Grammar::Modelica {
  rule TOP {^<within>$}
}
ok TestWithin.parse('within valid_name;');
ok TestWithin.parse('within valid_name ;');
nok TestWithin.parse('withinvalid_name;');
nok TestWithin.parse('valid_name;');
ok TestWithin.parse('within ;');
nok TestWithin.parse('within valid_name');

grammar TestClassDef is Grammar::Modelica {
  rule TOP {^<class_def>$}
  rule class_definition {'class_definition'}
}

ok TestClassDef.parse('final class_definition;');
ok TestClassDef.parse('class_definition;');
nok TestClassDef.parse('final class_definition');
nok TestClassDef.parse('final;');
nok TestClassDef.parse('finalclass_definition;');

grammar TestModelica is Grammar::Modelica {
  rule class_definition {'class_definition'}
}
ok TestModelica.parse('');
ok TestModelica.parse('within valid_ident;');
ok TestModelica.parse('within valid_ident; final class_definition;');
ok TestModelica.parse('within valid_ident; final class_definition;final class_definition;final class_definition;');
