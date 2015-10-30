use Test;
use Locale::Language;

is code2language('EN'), 'English';
is language2code('French'), 'FR';

is language2code('French', LOCALE_LANG_ALPHA_3), 'FRE';

my @codes = all_language_codes();
ok @codes.grep(/^EN$/);
ok @codes.grep(/^FR$/);

@codes = all_language_codes(LOCALE_LANG_ALPHA_3);
ok @codes.grep(/^ENG$/);
ok @codes.grep(/^FRE$/);

my @names = all_language_names();
ok @names.grep(/^English$/);
ok @names.grep(/^French$/);

done-testing();