use v6;
use lib 'lib';
use File::Presence;
use Test;

plan(1);

subtest({
    my Str:D $file = 't/methods/show.t';
    ok(File::Presence.exists-readwriteable-file($file));
    nok(File::Presence.exists-readwriteable-file('bzzt'));
});

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
