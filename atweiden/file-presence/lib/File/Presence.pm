use v6;
unit class File::Presence;

constant $VERSION = v0.0.1;

subset PresenceHash of Hash where { .keys.sort ~~ <dir exists file readable> }

method show(Str $file) returns PresenceHash
{
    my Bool $e = $file.IO.e;
    my Bool $d = False;
    my Bool $f = False;
    my Bool $r = False;

    if $e
    {
        $d = $file.IO.d;
        $f = $file.IO.f;
        $r = $file.IO.r;
    }

    my PresenceHash $p = %(:dir($d), :exists($e), :file($f), :readable($r));
}

sub exists-readable-dir(Str $dir) is export returns Bool
{
    my PresenceHash $p = File::Presence.show($dir);
    $p<exists> && $p<readable> && $p<dir>;
}

sub exists-readable-file(Str $file) is export returns Bool
{
    my PresenceHash $p = File::Presence.show($file);
    $p<exists> && $p<readable> && $p<file>;
}

# vim: ft=perl6 fdm=marker fdl=0
