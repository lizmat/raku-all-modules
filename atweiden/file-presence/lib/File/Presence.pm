use v6;
unit class File::Presence;

constant $VERSION = v0.0.3;

subset PresenceHash of Hash where { .keys.sort ~~ <d e f r w x> }

method show(Str $file) returns PresenceHash
{
    my Bool $e = $file.IO.e;
    my Bool $d = False;
    my Bool $f = False;
    my Bool $r = False;
    my Bool $w = False;
    my Bool $x = False;

    if $e
    {
        $d = $file.IO.d;
        $f = $file.IO.f;
        $r = $file.IO.r;
        $w = $file.IO.w;
        $x = $file.IO.x;
    }

    my PresenceHash $p = %(:$d, :$e, :$f, :$r, :$w, :$x);
}

sub exists-readable-dir(Str $dir) is export returns Bool
{
    my PresenceHash $p = File::Presence.show($dir);
    $p<e> && $p<r> && $p<d>;
}

sub exists-readwriteable-dir(Str $dir) is export returns Bool
{
    my PresenceHash $p = File::Presence.show($dir);
    $p<e> && $p<r> && $p<w> && $p<d>;
}

sub exists-readable-file(Str $file) is export returns Bool
{
    my PresenceHash $p = File::Presence.show($file);
    $p<e> && $p<r> && $p<f>;
}

sub exists-readwriteable-file(Str $file) is export returns Bool
{
    my PresenceHash $p = File::Presence.show($file);
    $p<e> && $p<r> && $p<w> && $p<f>;
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
