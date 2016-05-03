#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;
use PSGI;

plan(27);

sub p6sgi-v04-version (%env, $note)
{
  my $msg = 'P6SGI 0.4Draft version '~$note;
  is %env<p6sgi.version>, Version.new('0.4.Draft'), $msg;
}

sub no-v04-version (%env, $note)
{
  my $msg = 'No 0.4 version in '~$note;
  ok !(%env<p6sgi.version>:exists), $msg;
}

sub p6sgi-v07-version (%env, $note)
{
  my $msg = 'P6SGI 0.7Draft version '~$note;
  is %env<p6w.version>, Version.new('0.7.Draft'), $msg;
}

sub no-v07-version (%env, $note)
{
  my $msg = 'No 0.7 version in '~$note;
  ok !(%env<p6w.version>:exists), $msg;
}

sub psgi-classic-version (%env, $note)
{
  my $msg = 'PSGI Classic version '~$note;
  is %env<psgi.version>, [1,0], $msg;
}

sub no-classic-version (%env, $note)
{
  my $msg = 'No PSGI Classic version in '~$note;
  ok !(%env<psgi.version>:exists), $msg;
}

my $num-opt = 'with numeric :p6sgi option';

my %p6sgi-v4n-env;

populate-psgi-env(%p6sgi-v4n-env, :p6sgi(0.4));

p6sgi-v04-version(%p6sgi-v4n-env, $num-opt);
no-v07-version(%p6sgi-v4n-env, $num-opt);
no-classic-version(%p6sgi-v4n-env, $num-opt);

my %p6sgi-v7n-env;

populate-psgi-env(%p6sgi-v7n-env, :p6sgi(0.7));

p6sgi-v07-version(%p6sgi-v7n-env, $num-opt);
no-v04-version(%p6sgi-v7n-env, $num-opt);
no-classic-version(%p6sgi-v7n-env, $num-opt);

my $str-opt = 'with string :p6sgi option';

my %p6sgi-v4s-env;

populate-psgi-env(%p6sgi-v4s-env, :p6sgi<0.4Draft>);

p6sgi-v04-version(%p6sgi-v4s-env, $str-opt);
no-v07-version(%p6sgi-v4s-env, $str-opt);
no-classic-version(%p6sgi-v4s-env, $str-opt);

my %p6sgi-v7s-env;

populate-psgi-env(%p6sgi-v7s-env, :p6sgi<0.7Draft>);

p6sgi-v07-version(%p6sgi-v7s-env, $str-opt);
no-v04-version(%p6sgi-v7s-env, $str-opt);
no-classic-version(%p6sgi-v7s-env, $str-opt);

my $all-opt = 'with :p6sgi<all> option';

my %p6sgi-all-env;

populate-psgi-env(%p6sgi-all-env, :p6sgi<all>);

p6sgi-v04-version(%p6sgi-all-env, $all-opt);
p6sgi-v07-version(%p6sgi-all-env, $all-opt);
no-classic-version(%p6sgi-all-env, $all-opt);

my $latest-opt = 'with :p6sgi<latest> option';

my %p6sgi-latest-env;

populate-psgi-env(%p6sgi-latest-env, :p6sgi<latest>);

p6sgi-v07-version(%p6sgi-latest-env, $latest-opt);
no-v04-version(%p6sgi-latest-env, $latest-opt);
no-classic-version(%p6sgi-latest-env, $latest-opt);

my $def-opt = 'with default options';
my %p6sgi-def-env;

populate-psgi-env(%p6sgi-def-env);

p6sgi-v04-version(%p6sgi-def-env, $def-opt);
p6sgi-v07-version(%p6sgi-def-env, $def-opt);
no-classic-version(%p6sgi-def-env, $def-opt);

my $psgi-opt = 'with PSGI only';
my %psgi-classic-env;

populate-psgi-env(%psgi-classic-env, :psgi-classic, :!p6sgi);

psgi-classic-version(%psgi-classic-env, $psgi-opt);
no-v04-version(%psgi-classic-env, $psgi-opt);
no-v07-version(%psgi-classic-env, $psgi-opt);

my $combined-opt = 'with PSGI Classic and P6SGI default versions';
my %combined-env;

populate-psgi-env(%combined-env, :psgi-classic);

p6sgi-v04-version(%combined-env, $combined-opt);
p6sgi-v07-version(%combined-env, $combined-opt);
psgi-classic-version(%combined-env, $combined-opt);

## TODO: more comprehensive tests.

