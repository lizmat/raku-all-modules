#!/usr/bin/env perl6

use lib 'lib';
use lib 't/lib';
use Operator::feq;
use Test;
plan 7;

{
  my $*FEQTHRESHOLD = 1; #100% - all tests should be positive
  is "5000" feq '44', True, 'True regardless of distance 1';
  is '000' feq '888', True, 'True regardless of distance 2';
};

{
  my $*FEQTHRESHOLD = 0;
  is '5'  feq '5' , False, 'False regardless of distance 1';
  is 'aa' feq 'aa', False, 'False regardless of distance 2';
};

#default threshold is 10% (.1)
is '1234567890' feq '1234567899', True, 'Exactly 10% diff, expect 10% or less';
is '1234567888' feq '1234567890', False, 'More than 10% diff, expect 10% or less';

{
  my $*FEQLIB = 'Operator::feq::Test';
  my $*C = sub {
    ok True, 'Override default library -';
  };
  'a' feq 'b';
};

# vi:syntax=perl6
