use v6;
use lib 'lib';
use File::Presence;
use Test;

plan 1;

subtest
{
    my Str $dir = 't/methods';
    my Str $file = 't/methods/show.t';
    is-deeply File::Presence.show($dir), { :exists, :readable, :!file, :dir };
    is-deeply File::Presence.show($file), { :exists, :readable, :file, :!dir };
    is-deeply File::Presence.show('bzzt'), { :!exists, :!readable, :!file, :!dir };
}

# vim: ft=perl6 fdm=marker fdl=0
