use v6;
use Algorithm::BloomFilter;
use Test;

subtest {

    my Int %filter := Algorithm::BloomFilter.calculate-shortest-filter-length(
        num-keys   => 1092,
        error-rate => 0.00001
    );

    is %filter<length>, 26172;
    is %filter<num-hash-funcs>, 17;

}, 'Test calculate-shortest-filter-length';

subtest {

    subtest {

        my Int @salts = Algorithm::BloomFilter.create-salts(count => 1);

        is @salts.elems, 1;

    }, 'When 1';

    subtest {

        my Int @salts = Algorithm::BloomFilter.create-salts(count => 5);

        is @salts.elems, 5;

    }, 'When 5';

}, 'Test create-salts';

subtest {

    my Int @salts = Algorithm::BloomFilter.create-salts(count => 2);
    my Int @cells = Algorithm::BloomFilter.get-cells(
        'hogehoge',
        filter-length => 10,
        blankvec      => 0,
        salts         => @salts,
    );

    is @cells.elems, 2;

}, 'Test get-cells';

done-testing;
