use v6.c;
use Test;
use lib 'lib';
use Algorithm::SkewHeap;

my $size = 100;
my @nums = (1..$size).pick($size);

isa-ok my $heap = Algorithm::SkewHeap.new, 'Algorithm::SkewHeap', 'ctor';
is $heap.size, 0, 'size';
ok $heap.is-empty, 'is-empty';

for @nums -> $num {
  ok $heap.put($num), 'put';
}

is $heap.size, $size, 'size';
ok !$heap.is-empty, '!is-empty';

my $prev;
my $count = $heap.size;
while !$heap.is-empty {
  is $heap.size, $count, "size: $count"
    or bail-out;

  --$count;

  my $item = $heap.take // $heap.explain;
  ok $item, "take: $item";

  if ($prev.DEFINITE) {
    ok $item >= $prev, "$item >= $prev";
  }

  $prev = $item;
}

is $heap.size, 0, 'size';
ok $heap.is-empty, 'is-empty';

done-testing;
