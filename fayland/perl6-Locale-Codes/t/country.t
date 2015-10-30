use Test;
use Locale::Country;

is code2country('JP'), 'Japan';
is code2country('CHN'), 'China';
is code2country('250'), 'France';
is country2code('Norway'), 'NO';
is country2code('Norway', 'alpha-3'), 'NOR';
is country2code('Norway', 'numeric'), '578';

is country2code('Norway', LOCALE_CODE_ALPHA_2), 'NO';

my @codes = all_country_codes();
ok @codes.grep(/^JP$/);
ok @codes.grep(/^NO$/);

@codes = all_country_codes(LOCALE_CODE_ALPHA_3);
ok @codes.grep(/^CHN$/);
ok @codes.grep(/^NOR$/);

my @names = all_country_names();
ok @names.grep(/^China$/);
ok @names.grep(/^Norway$/);

done-testing();