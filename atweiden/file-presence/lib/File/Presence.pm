use v6;
unit class File::Presence;

constant $VERSION = v0.0.3;

subset PresenceHash of Hash where { .keys.sort ~~ <d e f r w x> }

method show(Str:D $file where *.so) returns PresenceHash:D
{
    my Bool:D $e = $file.IO.e;
    my Bool:D $d = False;
    my Bool:D $f = False;
    my Bool:D $r = False;
    my Bool:D $w = False;
    my Bool:D $x = False;

    if $e
    {
        $d = $file.IO.d;
        $f = $file.IO.f;
        $r = $file.IO.r;
        $w = $file.IO.w;
        $x = $file.IO.x;
    }

    my PresenceHash:D $p = %(:$d, :$e, :$f, :$r, :$w, :$x);
}

sub exists-readable-dir(Str:D $dir where *.so) is export returns Bool:D
{
    my PresenceHash:D $p = File::Presence.show($dir);
    $p<e> && $p<r> && $p<d>;
}

sub exists-readwriteable-dir(Str:D $dir where *.so) is export returns Bool:D
{
    my PresenceHash:D $p = File::Presence.show($dir);
    $p<e> && $p<r> && $p<w> && $p<d>;
}

sub exists-readable-file(Str:D $file) is export returns Bool:D
{
    my PresenceHash:D $p = File::Presence.show($file);
    $p<e> && $p<r> && $p<f>;
}

sub exists-readwriteable-file(Str:D $file) is export returns Bool:D
{
    my PresenceHash:D $p = File::Presence.show($file);
    $p<e> && $p<r> && $p<w> && $p<f>;
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
