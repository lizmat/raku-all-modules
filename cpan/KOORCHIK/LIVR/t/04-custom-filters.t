use lib 'lib';

use Test;
use LIVR;

LIVR::Validator.register-default-rules({
    'my_ucfirst' => sub ([], %builders) {
         return sub ($value, %all-values, $output is rw) {
            return if LIVR::Utils::is-no-value($value);

            $output = $value.tc;
            return;
        }
    },
    'my_lc' => sub ([], %builders) {
         return sub ($value, %all-values, $output is rw) {
            return if LIVR::Utils::is-no-value($value);

            $output = $value.lc;
            return;
        }
    },
    'my_trim' => sub ([], %builders) {
         return sub ($value, %all-values, $output is rw) {
            return if LIVR::Utils::is-no-value($value);

            $output = $value.trim;
            return;
        }
    }
});

subtest 'Validate data with registered rules' => sub {
    my $validator = LIVR::Validator.new(livr-rules => {
        word1 => ['my_trim', 'my_lc', 'my_ucfirst'],
        word2 => ['my_trim', 'my_lc'],
        word3 => ['my_ucfirst'],
    });

    my $output = $validator.validate({
        word1 => ' wordOne ',
        word2 => ' wordTwo ',
        word3 => 'wordThree ',
    });

    is-deeply $output, {
        word1 => 'Wordone',
        word2 => 'wordtwo',
        word3 => 'WordThree ',
    }, 'Should appluy changes to values';
};

done-testing;

