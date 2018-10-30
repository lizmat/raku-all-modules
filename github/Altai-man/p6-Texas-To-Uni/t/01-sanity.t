use v6;

use Test;
use Texas::To::Uni;

plan 1;

my Str $filename = 't/test-file1.p6';
my Str $new-name = 't/test-file1.uni.p6';
my Str $valid-output;

# Valid output.
my $proc-v = Proc::Async.new('perl6', $filename);

$proc-v.stdout.tap(-> $v { $valid-output = $v; });
$proc-v.stderr.tap(-> $v { fail $v });

await $proc-v.start;

convert-file($filename);

# # # Converted output.
my Str $converted;

my $proc-c = Proc::Async.new('perl6', $new-name);

$proc-c.stdout.tap(-> $v { $converted = $v; });
$proc-c.stderr.tap(-> $v { fail $v });

await $proc-c.start;

say $valid-output;
say $converted;

ok $valid-output eq $converted;
