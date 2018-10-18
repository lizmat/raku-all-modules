use v6.c;

use lib 'lib';
use Test;

plan 1;

use Proc::Async::Timeout;

my $s = Proc::Async::Timeout.new('sleep', '1m');

throws-like { await $s.start: timeout => 1 }, X::Proc::Async::Timeout, 'timeout hit';

