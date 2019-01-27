use v6;

use Test;

use Algorithm::Heap::Binary;

my @numbers = 1 .. *;
my @letters = 'a' .. *;
my @data = @numbers Z=> @letters;

sub test-values($heap, $list, $msg) {
    is-deeply($heap.Seq.map(*.value), $list, $msg);
}

sub test-keys($heap, $list, $msg) {
    is-deeply($heap.Seq.map(*.key), $list, $msg);
}

subtest {
    my $heap = Algorithm::Heap::Binary.new;

    ok($heap.size == 0, 'heap size == 0');
    ok($heap.is-empty, 'empty heap');

    $heap.insert(2 => 'b');
    $heap.insert(3 => 'c');
    $heap.insert(1 => 'a');

    ok($heap.size == 3, 'heap size == 3');

    test-values($heap, <a b c>, 'check order');

    ok($heap.size == 3, 'original heap not touched by Seq');

    done-testing;
}, 'size tests';

subtest {
    my $heap = Algorithm::Heap::Binary.new;

    $heap.insert(2 => 'b');
    $heap.insert(3 => 'c');
    $heap.insert(1 => 'a');

    is($heap.peek.value, 'a', 'peek method');
    is($heap.find-min.value, 'a', 'find-min method');
    is($heap.find-max.value, 'a', 'find-max method');

    done-testing;
}, 'peek tests';

subtest {
    my $heap = Algorithm::Heap::Binary.new(comparator => * <=> *, |@data[^5]);

    test-keys($heap, (^5 + 1).List, 'heapify keys');
    test-values($heap, <a b c d e>, 'heapify values');

    done-testing;
}, 'heapify test';

subtest {
    my $heap = Algorithm::Heap::Binary.new;
    $heap.insert(2 => 'second');
    $heap.insert(1 => 'first');
    test-values($heap, <first second>, 'void constructor');

    $heap = Algorithm::Heap::Binary.new(comparator => -> $a, $b {$b cmp $a});
    $heap.insert('a' => 1);
    $heap.insert('b' => 2);
    $heap.insert('c' => 3);
    test-keys($heap, <c b a>, 'named comparator');

    $heap = Algorithm::Heap::Binary.new(1 => 'first', 2 => 'second');
    test-values($heap, <first second>, 'hepify w/ default comparator');

    $heap = Algorithm::Heap::Binary.new(
        comparator => * cmp *,
        'alex' => 'cono',
        'cono' => 'alex'
    );
    test-keys($heap, <alex cono>, 'hepify w/ comparator');

    done-testing;
}, 'constructors';

subtest {
    my $heap = Algorithm::Heap::Binary.new;
    $heap.insert(2 => 'second');
    $heap.insert(1 => 'first');

    is($heap.size, 2, 'two insert');

    $heap.push(3 => 'third');

    is($heap.size, 3, 'and one push');
}, 'insert';

subtest {
    my $heap = Algorithm::Heap::Binary.new(|@data[^5]);

    is($heap.pop.value, 'a', 'pop method');
    is($heap.delete-min.value, 'b', 'delete-min method');
    is($heap.delete-max.value, 'c', 'delete-max method');

    test-keys($heap, (4, 5), 'test rest');
}, 'pop';

subtest {
    my $heap = Algorithm::Heap::Binary.new(|@data[^5]);

    is($heap.replace(42 => 'cono'), 1 => 'a', 'replace method');

    test-values($heap, <b c d e cono>, 'test rest');
}, 'replace';

subtest {
    my $heap1 = Algorithm::Heap::Binary.new(|@data[0,2,4]);
    my $heap2 = Algorithm::Heap::Binary.new(|@data[1,3]);

    my $merged = $heap1.merge($heap2);
    test-values($merged, <a b c d e>, 'new heap from merge');
}, 'merge';

done-testing;

# vim: ft=perl6
