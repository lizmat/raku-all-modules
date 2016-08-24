use v6;
use lib 'lib';
use File::Presence;
use Test;

plan 1;

subtest
{
    my Str $dir = 't/methods';
    my Str $file = 't/methods/show.t';
    is-deeply File::Presence.show($dir), { :e, :d, :!f, :r, :w, :x };
    is-deeply File::Presence.show($file), { :e, :!d, :f, :r, :w, :!x }
    is-deeply File::Presence.show('bzzt'), { :!e, :!d, :!f, :!r, :!w, :!x };
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
