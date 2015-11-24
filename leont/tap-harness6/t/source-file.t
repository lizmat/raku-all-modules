use v6;
use TAP;

use Test::More;

plan 4;

my $source = TAP::Runner::Source::File.new(:filename('t/source-file-test-data'));
my $parser = TAP::Runner::Async.new(:$source);
await $parser.waiter;
my $result = $parser.result;

is $result.tests-planned, 2;
is $result.tests-run, 2;
is-deeply [@( $result.passed.list )], [ 1 ];
is-deeply [@( $result.failed.list )], [ 2 ];
