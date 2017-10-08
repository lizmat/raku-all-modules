use Test;
use Locale::Currency;

is code2currency('usd'), 'US Dollar';
is code2currency('EUR'), 'Euro';
is code2currency('978'), 'Euro';
is currency2code('Euro'), 'EUR';
is currency2code('Euro', 'num'), '978';

my @codes = all_currency_codes();
ok @codes.grep(/^USD$/);
ok @codes.grep(/^EUR$/);

my @names = all_currency_names();
ok @names.grep(/^'US Dollar'$/);
ok @names.grep(/^Euro$/);

done-testing();