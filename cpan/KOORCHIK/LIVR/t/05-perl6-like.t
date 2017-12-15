use lib 'lib';

use Test;
use LIVR;

subtest 'POSITIVE: perl6 "like" rule implementation' => {
    my $validator = LIVR::Validator.new( livr-rules => {
        name   => { 'like' => rx/^ <[a..z]>+ $/ },
        gender => { 'like' => rx/^ (MALE|FEMALE) $/  }
    });

    my $validated = $validator.validate({
        name      => 'koorchik',
        gender    => 'MALE',
        somefield => 'This field has no validation'
    });

    ok $validated, 'Should return true on success validation';
    is-deeply $validated, {name => 'koorchik', gender => 'MALE'}, 'should return cleaned object';
};

subtest 'NEGATIVE: perl6 "like" rule implementation' => {
    my $validator = LIVR::Validator.new( livr-rules => {
        name   => { 'like' => rx/^ <[a..z]>+ $/ },
        gender => { 'like' => rx/^ (MALE|FEMALE) $/  }
    });

    my $validated = $validator.validate({
        name      => 'KOORCHIK',
        gender    => 'SOME',
        somefield => 'This field has no validation'
    });

    ok !$validated, 'Should return false on failed validation';
    is $validator.errors<name>, 'WRONG_FORMAT', '"name" should has error WRONG_FORMAT';
    is $validator.errors<gender>, 'WRONG_FORMAT', '"gender" should has error WRONG_FORMAT';
};

done-testing;
