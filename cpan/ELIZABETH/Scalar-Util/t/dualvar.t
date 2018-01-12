use v6.c;

use Scalar::Util <dualvar isdual>;
use Test;

plan 11;

ok defined(&dualvar), 'dualvar defined';
ok defined(&isdual),  'isdual defined';

my $var = dualvar( 2.2,"café");
ok isdual($var),     'Is a dualvar';
ok $var == 2.2,      'Numeric value';
ok $var eq "café", 'String value';

my $var2 = $var;
ok isdual($var2),     'Is a dualvar';
ok $var2 == 2.2,      'copy Numeric value';
ok $var2 eq "café", 'copy String value';

$var += 1;  # Rakudo GH 1387
ok !isdual($var),    'No longer dualvar';
ok $var == 3.2,      'inc Numeric value';
ok $var ne "café", 'inc String value';

# vim: ft=perl6 expandtab sw=4
