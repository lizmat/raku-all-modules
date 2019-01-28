use v6.c;
use Test;

use P5math;

plan 18;

for <&abs &cos &crypt &exp &int &log &rand &sin &sqrt> -> $name {
   ok OUTER::MY::<<$name>>:exists, "is $name imported by default?";
}

ok 0 < rand      <  1, 'did we get a random number between 0 and 1';
ok 0 < &rand(42) < 42, 'did we get a random number between 0 and 42';

for &abs, &cos, &exp, &log, &sin, &sqrt -> &func {
    $_ = 3.14;
    is func($_), func(), "Did we get it right for &func.name()"
}

is crypt("foo","ba"), crypt("foo","ba"), 'does crypt give the same';

# vim: ft=perl6 expandtab sw=4
