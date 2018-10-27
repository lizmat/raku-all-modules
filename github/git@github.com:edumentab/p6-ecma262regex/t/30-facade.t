use v6;
use ECMA262Regex;
use Test;

nok ECMA262Regex.validate('\e'), 'Invalid regex returns False';
ok ECMA262Regex.validate('^fo+\n'), 'Valid regex returns True';

is ECMA262Regex.as-perl6('^fo+\n'), '^fo+\n', 'Regex is translated';

my $regex = ECMA262Regex.compile('^fo+\n');

ok "foo\n" ~~ $regex, 'Regex is compiled, successful check';
nok " foo\n" ~~ $regex, 'Regex is compiled, failed check';

done-testing;
