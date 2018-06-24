use v6;
use lib 'lib';
use File::Presence;
use Test;

plan(1);

subtest({
    my Str:D $dir = 't/methods';
    ok(File::Presence.exists-readwriteable-dir($dir));
    nok(File::Presence.exists-readwriteable-dir('bzzt'));
});

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
