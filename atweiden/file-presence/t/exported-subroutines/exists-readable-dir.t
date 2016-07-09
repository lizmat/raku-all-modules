use v6;
use lib 'lib';
use File::Presence;
use Test;

plan 1;

subtest
{
    my Str $dir = 't/methods';
    ok exists-readable-dir($dir);
    nok exists-readable-dir('bzzt');
}

# vim: ft=perl6 fdm=marker fdl=0
