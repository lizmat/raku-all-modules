use v6;
use lib 'lib';
use File::Presence;
use Test;

plan 1;

subtest
{
    my Str $dir = 't/methods';
    ok exists-readwriteable-dir($dir);
    nok exists-readwriteable-dir('bzzt');
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
