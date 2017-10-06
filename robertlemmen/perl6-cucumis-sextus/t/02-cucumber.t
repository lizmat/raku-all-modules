#!/usr/bin/env perl6

use v6;

use Test;

use CucumisSextus::Core;
use CucumisSextus::Gherkin;
use CucumisSextus::Tags;

use lib 't/features/step_definitions';
use StepDefs;

clear-trace;
my $feature;
my $result = CucumisResult.new;
lives-ok({ $feature = parse-feature-file('t/features/basic.feature') }, "Parsing a basic feature should work");
lives-ok({ execute-feature($feature, [], $result) } , "Executing the feature should work");
is(get-trace, 'AC1F1', 'All steps have executed in right order');
is($result.succeeded, 1, 'All steps succeeded');
is($result.failed, 0, 'No steps failed');

lives-ok({ $feature = parse-feature-file('t/features/broken-ambiguous.feature') }, "Parsing a basic feature should work");
throws-like({ execute-feature($feature, [], $result) } , X::CucumisSextus::FeatureExecFailure, 
    "Executing a feature with ambigous step defs should fail");

lives-ok({ $feature = parse-feature-file('t/features/broken-missing-glue.feature') }, "Parsing a basic feature should work");
throws-like({ execute-feature($feature, [], $result) } , X::CucumisSextus::FeatureExecFailure, 
    "Executing a feature with missing steps should fail");

lives-ok({ $feature = parse-feature-file('t/features/broken-verbs-mismatch.feature') }, "Parsing a basic feature should work");
throws-like({ execute-feature($feature, [], $result) } , X::CucumisSextus::FeatureExecFailure, 
    "Executing a feature with glue/step verb mismatch should fail");

lives-ok({ $feature = parse-feature-file('t/features/broken-signature.feature') }, "Parsing a basic feature should work");
throws-like({ execute-feature($feature, [], $result) } , X::CucumisSextus::FeatureExecFailure, 
    "Executing a feature against glue code with mismatched signature should fail");

clear-trace;
$result = CucumisResult.new;
lives-ok({ $feature = parse-feature-file('t/features/basic-german.feature') }, "Parsing a feature file in german should work");
lives-ok({ execute-feature($feature, [], $result) } , "Executing the german feature should work");
is(get-trace, 'AdeD1deF1de', 'All steps have executed in right order');
is($result.succeeded, 1, 'All steps succeeded');
is($result.failed, 0, 'No steps failed');

clear-trace;
$result = CucumisResult.new;
lives-ok({ $feature = parse-feature-file('t/features/slurpy.feature') }, "Parsing a feature with slupy args should work");
lives-ok({ execute-feature($feature, [], $result) } , "Executing the slurpy feature/glue code should work");
is(get-trace, 'AC1C2C3C+C4C5C6C+F579', 'All steps have executed in right order');
is($result.succeeded, 1, 'All steps succeeded');
is($result.failed, 0, 'No steps failed');

clear-trace;
$result = CucumisResult.new;
lives-ok({ $feature = parse-feature-file('t/features/basic-table.feature') }, "Parsing a feature with a table should work");
lives-ok({ execute-feature($feature, [], $result) } , "Executing the feature with table should work");
is(get-trace, 'AT0.5+0.1T0.01/0.01T10*1C3F3', 'All steps have executed in right order');
is($result.succeeded, 1, 'All steps succeeded');
is($result.failed, 0, 'No steps failed');

clear-trace;
$result = CucumisResult.new;
lives-ok({ $feature = parse-feature-file('t/features/basic-hooked.feature') }, "Parsing a feature with hooks should work");
lives-ok({ execute-feature($feature, [], $result) } , "Executing the feature with hooks should work");
is(get-trace, '[AC1F1]', 'All steps and hooks have executed in right order');
is($result.succeeded, 1, 'All steps succeeded');
is($result.failed, 0, 'No steps failed');

clear-trace;
$result = CucumisResult.new;
lives-ok({ $feature = parse-feature-file('t/features/basic-examples.feature') }, "Parsing a feature with examples should work");
lives-ok({ execute-feature($feature, [], $result) } , "Executing the feature with examples should work");
is(get-trace, 'At5.0t+t5.0C=F10At6t/t3C=F2At10t*t7.550C=F75.5At3t-t10C=F-7', 'All steps and hooks have executed in right order');
is($result.succeeded, 4, 'All steps succeeded');
is($result.failed, 0, 'No steps failed');

clear-trace;
$result = CucumisResult.new;
lives-ok({ $feature = parse-feature-file('t/features/basic-multiline.feature') }, "Parsing a feature with multiline strings should work");
lives-ok({ execute-feature($feature, [], $result) } , "Executing the feature with multiline strings should work");
is(get-trace, "AU1 + 2 + 3 + 4 + 5 + 6 -\n100\n* 13 \\=\\=\\= + 2 =F-1025", 'All steps and hooks have executed in right order');
is($result.succeeded, 1, 'All steps succeeded');
is($result.failed, 0, 'No steps failed');

clear-trace;
$result = CucumisResult.new;
lives-ok({ $feature = parse-feature-file('t/features/basic-tagged.feature') }, "Parsing a feature with tags should work");
lives-ok({ execute-feature($feature, [ parse-filter('~@positive')], $result) } , "Executing the feature with tags should work");
is(get-trace, "", 'All steps and hooks have executed in right order');
is($result.executed, 0, 'No step should have been executed');
is($result.skipped, 1, 'One step got skipped');

clear-trace;
$result = CucumisResult.new;
lives-ok({ $feature = parse-feature-file('t/features/basic-failure.feature') }, "Parsing a feature with failing steps should work");
lives-ok({ execute-feature($feature, [], $result) } , "Executing the feature with failing steps should work");
is(get-trace, "AC1F1AC1C2C3C.C5C0V1AC1C2C3CCF0", 'All steps and hooks have executed in right order');
is($result.succeeded, 2, 'All steps succeeded');
is($result.failed, 1, 'One step failed');

done-testing;
