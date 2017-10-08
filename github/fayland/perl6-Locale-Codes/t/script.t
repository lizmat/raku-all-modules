use Test;
use Locale::Script;

is code2script('phnx'), 'Phoenician';
is script2code('Phoenician'), 'Phnx';
is script2code('Phoenician', 'num'), '115';

my @codes = all_script_codes();
ok @codes.grep(/^Phnx$/);

my @names = all_script_names();
ok @names.grep(/^Phoenician$/);

done-testing();