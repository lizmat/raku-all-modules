use v6;
use Algorithm::BloomFilter;
use Test;

subtest {

    subtest {

        dies-ok { Algorithm::BloomFilter.new }, 'Dies without error-rate and capacity';
        dies-ok { Algorithm::BloomFilter.new(error-rate => 0.001) }, 'Dies without error-rate';
        dies-ok { Algorithm::BloomFilter.new(capacity => 10000) }, 'Dies without capacity';

    }, 'Fails with invalid parameters';

    subtest {

        my Algorithm::BloomFilter $bloom .= new(
            error-rate => 0.1,
            capacity   => 10,
        );

        isa-ok $bloom, 'Algorithm::BloomFilter';
        is $bloom.error-rate, 0.1;
        is $bloom.capacity,   10;
        is $bloom.key-count,  0;
        is $bloom.filter-length,  49;
        is $bloom.num-hash-funcs, 3;
        is $bloom.salts.elems,    3;

    }, 'Succeeds with valid parameters';

}, 'Test new';

subtest {

    dies-ok { Algorithm::BloomFilter.add('hogehoge') };
    dies-ok { Algorithm::BloomFilter.check('hogehoge') };

}, 'Test `add` and `check` are instance method';

subtest {

    my Algorithm::BloomFilter $bloom .= new(
        error-rate => 0.01,
        capacity   => 100,
    );

    lives-ok { $bloom.add('hogehoge') };

    ok $bloom.check('hogehoge');
    ok !$bloom.check('fugafuga');

}, 'Test add/check';

subtest {

    my Algorithm::BloomFilter $bloom .= new(
        error-rate => 0.1,
        capacity   => 2,
    );

    $bloom.add('hogehoge');
    $bloom.add('fugafuga');

    dies-ok { $bloom.add('foobar') };

}, 'Test add exceeds capacity';

done-testing;
