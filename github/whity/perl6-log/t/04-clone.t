use v6;

use Test;
use Log;

my $log   = Log.new;
$log.ndc.push('dummy');
$log.mdc.put('dummy', 1.Str);

my $clone = $log.clone;

isnt($clone.WHERE, $log.WHERE, 'log different memory address');

is($clone.pattern, $log.pattern, 'log same pattern');
is($clone.output, $log.output, 'log same output');
is($clone.level, $log.level, 'log same level');

is-deeply($clone.mdc.Hash, $log.mdc.Hash, 'mdc same elements');
is-deeply($clone.ndc.Array, $log.ndc.Array, 'ndc same elements');

done-testing;
