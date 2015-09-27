#!/usr/bin/env perl6
use Test;
use lib 'lib';
use Pod::Perl5::Grammar;
use Pod::Perl5::ToMarkdown;

plan 3;

my $target_html = 'test-corpus/readme_example.mkdn'.IO.slurp;

ok my $actions = Pod::Perl5::ToMarkdown.new, 'constructor';
ok my $match   = Pod::Perl5::Grammar.parsefile('test-corpus/readme_example.pod', :$actions),
  'convert string to html';
is $match.made, $target_html, 'Generated html matches expected';
