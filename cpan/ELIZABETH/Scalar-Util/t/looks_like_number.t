use v6.c;

use Scalar::Util <looks_like_number>;
use Test;

plan 6;

ok defined(&looks_like_number), 'looks_like_number defined';

for <42 42.2 42E0 42+3i> {
    ok looks_like_number($_), qq/does "$_" look like a number?/;
}
nok looks_like_number("ab"), 'does "ab" NOT look like a number?';

# vim: ft=perl6 expandtab sw=4
