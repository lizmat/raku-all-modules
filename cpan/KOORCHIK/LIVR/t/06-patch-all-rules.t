use lib 'lib';

use Test;
use LIVR;

my $default-rules = LIVR::Validator.get-default-rules();

for %$default-rules.kv -> $rule-name, $rule-builder {
    LIVR::Validator.register-default-rules($rule-name => sub (@args, %builders) {
        my $value-validator = $rule-builder(@args, %builders);
        
        return sub ($value, $all-values, $output is rw)  {        
            my $error = $value-validator($value, $all-values, $output);

            die "ERROR: $error" if $error;
            return;
        }
    });
}


subtest 'POSITIVE: Validate data with registered rules' => sub {
    my $validator = LIVR::Validator.new(livr-rules => {
        name  => 'required',
        email => [ 'required', 'email' ],
    });

    lives-ok { $validator.prepare() }, 'Should build all rules';
    
    ok my $clean-data = $validator.validate({
        name  => 'koorchik', 
        email => 'user@mail.com',
        some  => 'this field should be removed'
    }), 'should return clean data';

    is-deeply $clean-data, {
        name  => 'koorchik', 
        email => 'user@mail.com'
    }, 'Should contain valid data';
};

subtest 'NAGATIVE: Validate data with registered rules' => sub {
    my $validator = LIVR::Validator.new(livr-rules => {
        name  => 'required',
        email => [ 'required', 'email' ],
    });

    lives-ok { $validator.prepare() }, 'Should build all rules';
    dies-ok { $validator.validate({ 
        name  => '', 
        email => '' 
    }) }, "Should throw error on validation fail";
};

done-testing;
