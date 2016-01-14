#!/usr/bin/env perl6
use Test;
use lib 'lib';
use Pod::Perl5::Grammar;
use Pod::Perl5::ToHTML;

plan 5;

my $target_html = 't/test-corpus/readme_example.html'.IO.slurp;

ok my $actions = Pod::Perl5::ToHTML.new, 'constructor';
ok my $match   = Pod::Perl5::Grammar.parsefile('t/test-corpus/readme_example.pod', :$actions),
  'convert string to html';
is $match.made, $target_html, 'Generated html matches expected';
is $actions.head, '<meta charset="UTF-8">', 'head matches expected';
ok $actions.body, 'body is populated';
