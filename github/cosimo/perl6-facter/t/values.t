use v6;
use Test;
use Facter::Util::Values;

my @values = (
    'ABC123', 'abc123',
    '123', '123',
    'xyz', 'xyz',
);

for @values -> $test_case, $expected_result {
    is(
        Facter::Util::Values.convert($test_case), $expected_result,
        "convert() of String '$test_case' holds '$expected_result'",
    );
}

done;

