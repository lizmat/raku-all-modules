use v6.c;

use Scalar::Util <isvstring>;
use Test;

plan 3;

ok defined(&isvstring), 'isvstring defined';

ok isvstring(v6.c), 'is v6.c a vstring';
nok isvstring("foo"), 'is foo NOT a vstring';

# vim: ft=perl6 expandtab sw=4
