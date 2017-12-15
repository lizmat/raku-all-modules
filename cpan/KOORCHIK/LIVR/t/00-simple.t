use lib 'lib';

use Test;
use LIVR;

subtest 'POSITIVE: required' => {
    my $validator = LIVR::Validator.new( livr-rules => {
        name  => ['required'],
        email => { 'required' => [] }
    });

    my $validated = $validator.validate({
        name      => 'koorchik',
        email     => 'koorchik@gmail.com',
        somefield => 'This field has no validation'
    });

    ok $validated, 'Should return true on success validation';
    is-deeply $validated, {name => 'koorchik', email => 'koorchik@gmail.com'}, 'should return cleaned object';
};

subtest 'NEGATIVE: required' => {
    my $validator = LIVR::Validator.new(livr-rules => {
        name  => ['required'],
        email => { 'required' => [] }
    });

    my $validated = $validator.validate({
        name => ''
    });

    ok !$validated, 'Should return false on failed validation';
    is $validator.errors<name>, 'REQUIRED', '"name" should has error REQUIRED';
    is $validator.errors<email>, 'REQUIRED', '"email" should has error REQUIRED';
};

done-testing;
