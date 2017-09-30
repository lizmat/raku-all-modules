#!/usr/bin/env perl6

use v6;

use Test;

use CucumisSextus::Core;
use CucumisSextus::Gherkin;

use lib 't/features/step_definitions';
use StepDefs;

clear-trace;
my $feature;
lives-ok({ $feature = parse-feature-file('t/features/basic.feature') }, "Parsing a basic feature should work");
lives-ok({ execute-feature($feature, []) } , "Executing the feature should work");
is(get-trace, 'AC1F1', 'All steps have executed in right order');

lives-ok({ $feature = parse-feature-file('t/features/broken-ambiguous.feature') }, "Parsing a basic feature should work");
throws-like({ execute-feature($feature, []) } , X::CucumisSextus::FeatureExecFailure, 
    "Executing a feature with ambigous step defs should fail");

lives-ok({ $feature = parse-feature-file('t/features/broken-missing-glue.feature') }, "Parsing a basic feature should work");
throws-like({ execute-feature($feature, []) } , X::CucumisSextus::FeatureExecFailure, 
    "Executing a feature with missing steps should fail");

lives-ok({ $feature = parse-feature-file('t/features/broken-verbs-mismatch.feature') }, "Parsing a basic feature should work");
throws-like({ execute-feature($feature, []) } , X::CucumisSextus::FeatureExecFailure, 
    "Executing a feature with glue/step verb mismatch should fail");

lives-ok({ $feature = parse-feature-file('t/features/broken-signature.feature') }, "Parsing a basic feature should work");
throws-like({ execute-feature($feature, []) } , X::CucumisSextus::FeatureExecFailure, 
    "Executing a feature against glue code with mismatched signature should fail");

clear-trace;
lives-ok({ $feature = parse-feature-file('t/features/slurpy.feature') }, "Parsing a feature with slupy args should work");
lives-ok({ execute-feature($feature, []) } , "Executing the slurpy feature/glue code should work");
is(get-trace, 'AC1C2C3C+C4C5C6C+F579', 'All steps have executed in right order');

clear-trace;
lives-ok({ $feature = parse-feature-file('t/features/basic-table.feature') }, "Parsing a feature with a table should work");
lives-ok({ execute-feature($feature, []) } , "Executing the feature with table should work");
is(get-trace, 'AT0.5+0.1T0.01/0.01T10*1C3F3', 'All steps have executed in right order');

clear-trace;
lives-ok({ $feature = parse-feature-file('t/features/basic-hooked.feature') }, "Parsing a feature with hooks should work");
lives-ok({ execute-feature($feature, []) } , "Executing the feature with hooks should work");
is(get-trace, '[AC1F1]', 'All steps and hooks have executed in right order');

done-testing;
