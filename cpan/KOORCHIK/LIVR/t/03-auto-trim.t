use lib 'lib';

use Test;
use LIVR;

my $validator = LIVR::Validator.new(livr-rules => {
    code           => 'required',
    password       => ['required', { min_length => 3 }],
    address        => { nested_object  => {
        street   => { 'min_length' => 5 },
    } }
}, is-auto-trim => True);

subtest 'Validate data with automatic trim' => sub {
    lives-ok { $validator.prepare() }, 'Should build all rules';

    ok !$validator.validate({
        code => '  ',
        password => ' 12  ',
        address => {
            street   => '  hell '
        }
    }), 'should return false due to validation errors for trimmed values';

    is-deeply $validator.errors(), {
        code     =>'REQUIRED',
        password => 'TOO_SHORT',
        address  => {
            street   => 'TOO_SHORT',
        }
    }, 'Should contain error codes';
};

subtest 'Validate data with automatic trim' => sub {
    lives-ok { $validator.prepare() }, 'Should build all rules';

    ok my $clean-data = $validator.validate({
        code => ' A ',
        password => ' 123  ',
        address => {
            street   => '  hello '
        }
    }), 'should return clean data';

    is-deeply $clean-data, {
        code     =>'A',
        password => '123',
        address  => {
            street   => 'hello',
        }
    }, 'Should contain trimmed data';
};


done-testing;