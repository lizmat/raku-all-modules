use v6;
use Test;
use Hash::Consistent;

lives-ok {
    my $ch = Hash::Consistent.new(mult=>2);
}, 'basic instantiation';

dies-ok {
    my $ch = Hash::Consistent.new();
}, 'catch failure to include mult param';

dies-ok {
    my $ch = Hash::Consistent.new(mult=>'hello');
}, 'catch failure to include mult param as PosInt (1)';

dies-ok {
    my $ch = Hash::Consistent.new(mult=>0);
}, 'catch failure to include mult param as PosInt (2)';

dies-ok {
    my $ch = Hash::Consistent.new(mult=>1);
    $ch.insert('');
}, 'catch attempt to insert empty string';

dies-ok {
    my $ch = Hash::Consistent.new(mult=>1);
    $ch.remove('');
}, 'catch attempt to remove empty string';

dies-ok {
    my $ch = Hash::Consistent.new(mult=>1);
    my $r = $ch.find('');
}, 'catch attempt to find empty string';

lives-ok {
    my $ch = Hash::Consistent.new(mult=>2);
    isa-ok($ch,Hash::Consistent,'isa Hash::Consistent');
    my $ch_clone = $ch.clone;
    isa-ok($ch_clone,Hash::Consistent,'clone isa Hash::Consistent');
    is $ch_clone.mult, 2, '  empty clone has right mult';
}, 'clone';

lives-ok {
    my $ch = Hash::Consistent.new(mult=>2);
    $ch.insert('hello');
    $ch.insert('there');
    is $ch.sum_list.elems(), 4, '  correct hash cardinality';
}, 'cardinality on insert';

lives-ok {
    my $ch = Hash::Consistent.new(mult=>2);
    $ch.insert('foo');
    is $ch.sum_list.elems(), 2, '  correct hash cardinality';
    $ch.remove('bar');
    is $ch.sum_list.elems(), 2, '  correct hash cardinality';
    $ch.remove('foo');
    is $ch.sum_list.elems(), 0, '  correct hash cardinality';
    $ch.remove('foo');
    is $ch.sum_list.elems(), 0, '  correct hash cardinality';
}, 'cardinality on remove';

lives-ok {
    my $ch = Hash::Consistent.new(mult=>2);
    my $result = $ch.find('hooray');
    CATCH {
        when X::Hash::Consistent::IsEmpty {}
    }
}, 'caught exception for find in empty hash';

lives-ok {
    my $ch = Hash::Consistent.new(mult=>2);
    my constant $foo = 'foo';
    my constant $bar = 'bar';
    $ch.insert($foo);
    $ch.insert($bar);
    
    # gives this consistent hash:
    # 0: 2856785838 [crc32 of foo.1 derived from foo]
    # 1: 2884040318 [crc32 of bar.1 derived from bar]
    # 2: 3705784040 [crc32 of bar.0 derived from bar]
    # 3: 3711969080 [crc32 of foo.0 derived from foo]

    is $ch.find('hello'), $foo, 'found correct entry (1)';
    is $ch.find('hello there my name is Camelia. I like to program'), $bar, 'found correct entry (2)';
    
}, 'found results where they were expected';

lives-ok {
    my $ch = Hash::Consistent.new(mult=>2);
    $ch.insert('example.org');
    $ch.insert('example.com');
    is $ch.sum_list.elems(), 4, 'correct hash cardinality';
    # > $ch.print();
    # 0: 2725249910 [crc32 of example.org.0 derived from example.org]
    # 1: 3210990709 [crc32 of example.com.1 derived from example.com]
    # 2: 3362055395 [crc32 of example.com.0 derived from example.com]
    # 3: 3581359072 [crc32 of example.org.1 derived from example.org]

    # > String::CRC32::crc32('blah');
    # 3458818396
    # (should find next at 3581359072 -> example.org)
    is $ch.find('blah'), 'example.org', 'found correct entry (1)';

    # > String::CRC32::crc32('whee');
    # 3023755156
    # (should find next at 3210990709 -> example.com)
    is $ch.find('whee'), 'example.com', 'found correct entry (2)';
}, 'found results where they were expected';

done-testing;
