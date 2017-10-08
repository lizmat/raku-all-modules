#!/usr/bin/env perl6

use v6;

use Test;

use CucumisSextus::Gherkin;

dies-ok({ parse-feature-file('t/features/invalid.feature') }, "Parsing an absent file should fail");

my $feature;
# very simple feature file
lives-ok({ $feature = parse-feature-file('t/features/basic.feature') }, "Parsing an existing file should not die");
isa-ok($feature, CucumisSextus::Gherkin::Feature, "Parsing a feature file reurns a Feature object");
is($feature.scenarios.elems, 1, "Parsed feature file should have right number of scenarios");

# broken case: and before other step
throws-like({ $feature = parse-feature-file('t/features/broken-and.feature') }, 
    X::CucumisSextus::FeatureParseFailure, "Parsing a feature file with and before other step in scenario should fail");

# broken case: multiple features
throws-like({ $feature = parse-feature-file('t/features/broken-multi-feature.feature') }, 
    X::CucumisSextus::FeatureParseFailure, "Parsing a feature file with multiple features should fail");

# broken case: scenario without feature
throws-like({ $feature = parse-feature-file('t/features/broken-scenario-only.feature') }, 
    X::CucumisSextus::FeatureParseFailure, "Parsing a feature file with scenario but no feature should fail");

# full-featured feature file
lives-ok({ $feature = parse-feature-file('t/features/calculator.feature') }, "Parsing an existing file should not die");
isa-ok($feature, CucumisSextus::Gherkin::Feature, "Parsing a feature file reurns a Feature object");
is($feature.scenarios.elems, 9, "Parsed feature file should have right number of scenarios");

done-testing;
