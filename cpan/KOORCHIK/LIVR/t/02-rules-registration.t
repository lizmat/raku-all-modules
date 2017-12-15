use lib 'lib';

use Test;
use LIVR;

LIVR::Validator.register-default-rules(
    'strong_password' => sub ([], %builders) {
        return sub ($value, %all-values, $output is rw) {
            return if LIVR::Utils::is-no-value($value);
            return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;

            return 'WEAK_PASSWORD' if $value.chars < 6;
            return;
        }
    }
);

my $validator = LIVR::Validator.new(livr-rules => {
    code           => 'alphanumeric',
    password       => 'strong_password',
    address        => { nested_object  => {
        street   => 'alphanumeric',
        password => 'strong_password'
    } }
});

$validator.register-rules( 'alphanumeric' => sub ([], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if LIVR::Utils::is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;

        return 'NOT_ALPHANUMERIC' if $value !~~ rx:P5/^[a-z0-9]+$/;
        return;
    }
});

subtest 'Check default rules existence' => sub {
    my %rules = LIVR::Validator.get-default-rules();
    ok %rules<strong_password> ~~ Block, 'Default rules should contain "strong_password" rule';
    ok !(%rules<alphanumeric>:exists), 'Default rules should not contain "alphanumeric" rule';
};


subtest 'Check validator rules existence' => sub {
    my $rules = $validator.get-rules();
    ok $rules<strong_password> ~~ Block, 'Validator rules should contain "strong_password" rule';
    ok $rules<alphanumeric> ~~ Block, 'Validator rules should contain "alphanumeric" rule';
};


subtest 'Validate data with registered rules' => sub {
    lives-ok { $validator.prepare() }, 'Should build all rules';

    ok !$validator.validate({
        code => '!qwe',
        password => 123,
        address => {
            street   => 'Some Street!',
            password => 'qwer'
        }
    }), 'should return false due to validation errors';

    is-deeply $validator.errors(), {
        code     =>'NOT_ALPHANUMERIC',
        password => 'WEAK_PASSWORD',
        address  => {
            street   => 'NOT_ALPHANUMERIC',
            password => 'WEAK_PASSWORD'
        }
    }, 'Should contain error codes';
};

done-testing;
