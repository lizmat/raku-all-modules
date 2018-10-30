use Test;

plan 3;

use Lingua::Unihan;

my $value = unihan_query('kMandarin', '林');
ok $value eq 'lín';

my @value = unihan_query('kMandarin', '我爱你');
is @value.join('-'), "wǒ-ài-nǐ";

my $stroke = unihan_query('kTotalStrokes', '林');
is $stroke, 8;

