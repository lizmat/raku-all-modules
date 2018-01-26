#!/usr/bin/env perl6
use Test;
use lib 'lib';
use Pod::PerlTricks::Grammar;

plan 4;

use Pod::PerlTricks::ToHTML; pass 'import module';

ok my $actions = Pod::PerlTricks::ToHTML.new, 'constructor';
ok my $match = Pod::PerlTricks::Grammar.parsefile('test-corpus/SampleArticle.pod', :$actions), 'Match sample pod';
my $expected_html = 'test-corpus/SampleArticle.html'.IO.slurp;
is $match.made, $expected_html, 'Output HTML matches expected';
