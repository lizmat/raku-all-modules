use lib 'lib';

use Test;
use LIVR;

LIVR::Validator.register-aliased-default-rule({
    name  => 'strong_password',
    rules => {min_length => 6},
    error => 'WEAK_PASSWORD' 
});

subtest 'POSITIVE: strong_password' => {
    my $validator = LIVR::Validator.new( livr-rules => {
        password  => ['required', 'strong_password']
    });

    my $validated = $validator.validate({
        password => 123456
    });

    ok $validated, 'Should return true on success validation';
    is-deeply $validated, {password => '123456'}, 'should return cleaned object';
};

subtest 'NEGATIVE: strong_password' => {
    my $validator = LIVR::Validator.new( livr-rules => {
        password  => ['required', 'strong_password']
    });

    my $validated = $validator.validate({
        password => 'qaz'
    });

    ok !$validated, 'Should return false on failed validation';
    is $validator.errors<password>, 'WEAK_PASSWORD', '"password" should has error WEAK_PASSWORD';
};


done-testing;

