#!/usr/bin/env perl6

use lib 'lib';
use LREP;

sub hmm {
  my $x = "hello";
  say "I am at $?FILE : $?LINE";
  LREP::here;
  say $x;
}

hmm;

# So run this like:
#
# > $x
# hello
# > $x = "bye"
# bye
# > ^D
# bye

