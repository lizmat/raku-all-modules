use Test;
use Concurrent::Iterator;

plan 7;

my $ci = concurrent-iterator(1..Inf);
isa-ok $ci, Concurrent::Iterator, 'concurrent-iterator(...) returns a ConcurrentIterator';
is $ci.pull-one, 1, 'Correct first value from iterator';
is $ci.pull-one, 2, 'Correct second value from iterator';

my $cs = concurrent-seq(5..Inf);
isa-ok $cs, Seq, 'concurrent-seq returns a Seq';
my $csi = $cs.iterator;
isa-ok $csi, Concurrent::Iterator, 'That Seq contains a Concurrent::Iterator';
is $csi.pull-one, 5, 'Correct first value from iterator from Seq';
is $csi.pull-one, 6, 'Correct second value from iterator from Seq';
