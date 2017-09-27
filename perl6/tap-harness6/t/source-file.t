use v6;
use TAP;

use Test;

plan 4;

my $source = TAP::Source::File.new(:filename('t/source-file-test-data'));
my $parser = TAP::Async.new(:$source);
await $parser.waiter;
my $result = $parser.result;

is($result.tests-planned, 2, "planned 2");
is($result.tests-run, 2, "Ran 2");
is-deeply([@( $result.passed.list )], [ 1 ], "First test passed");
is-deeply([@( $result.failed.list )], [ 2 ], "Second test failed");
