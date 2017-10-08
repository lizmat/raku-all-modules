#!/usr/bin/env perl6

use JSON::Fast;
use Test;
use lib 'lib';
use System::Query;
use Data::Dump;

my $json-str = 't/data/one.json'.IO.slurp;
my %one = from-json $json-str;

my $x = system-collapse(%one);

plan 5;

my $xrun = 'null-make';

if $*DISTRO.name eq 'macosx' {
  my @l = [Version.new(10.0), Version.new(9.0), Version.new(8.0)].sort.reverse;
  for @l -> $v {
    $xrun = $v, last
      if $*DISTRO.version cmp $v ~~ Same ||
         $*DISTRO.version cmp $v ~~ More;
  }
  $xrun = "{$xrun.parts[0]}make";
} elsif $*DISTRO.name eq 'win32' {
  my @l = [Version.new(6), Version.new(5)].sort.reverse;
  for @l -> $v {
    $xrun = $v, last
      if $*DISTRO.version cmp $v ~~ Same ||
         $*DISTRO.version cmp $v ~~ More;
  }
  $xrun = "{$xrun.parts[0]}make";
}

ok $x<nested><test> eq 'data', 'no decision making for $_<nested><test>';
ok $x<nested2><test2> eq 'data2', 'no decision making for $_<nested2><test2>';
ok $x<default-test><second-test> eq 'string-val, no decisions', '$_<default-test><second-test>';
ok $x<default-test><first-test> eq 'default-option1', '$_<default-test><first-test> is using the default empty key';
ok $x<options><run> eq $xrun, '$_<options><run> is set to ' ~ $xrun;
