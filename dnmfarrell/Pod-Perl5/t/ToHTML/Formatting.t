#!/usr/bin/env perl6
use Test;
use lib 'lib';
use Pod::Perl5::Grammar;
use Pod::Perl5::ToHTML;

plan 3;

my $target_html = 't/test-corpus/formatting_codes.html'.IO.slurp;

ok my $actions = Pod::Perl5::ToHTML.new, 'constructor';
ok my $match   = Pod::Perl5::Grammar.parsefile('t/test-corpus/formatting_codes.pod', :$actions), 'convert string to html';
is $match.made, $target_html, 'Generated html matches expected';
