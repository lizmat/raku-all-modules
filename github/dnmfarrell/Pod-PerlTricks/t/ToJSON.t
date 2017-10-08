#!/usr/bin/env perl6
use Test;
use lib 'lib';
use Pod::PerlTricks::Grammar;

plan 4;

use Pod::PerlTricks::ToJSON; pass 'import module';
ok my $actions = Pod::PerlTricks::ToJSON.new, 'constructor';
ok my $match = Pod::PerlTricks::Grammar.parsefile('test-corpus/SampleArticle.pod', :$actions), 'parse article';

my $expected_json = 'test-corpus/SampleArticle.json'.IO.slurp;
is $match.made ~ "\n", $expected_json, 'Output JSON matches expected';
