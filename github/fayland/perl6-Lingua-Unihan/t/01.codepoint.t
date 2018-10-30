use Test;

plan 3;

use Lingua::Unihan;

my $value = unihan_codepoint('林');
ok $value eq '6797';

$value = unihan_codepoint('北');
is $value, '5317';

$value = unihan_codepoint('你');
is $value, '4f60';

