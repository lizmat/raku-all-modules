use v6;
unit class File::Presence;

constant $VERSION = v0.0.3;

subset PresenceHash of Hash where { .keys().sort() ~~ <d e f r w x> }

multi method show(Str:D $file where *.so() && *.IO.e().so() --> PresenceHash:D)
{
    my Bool:D $e = True;
    my Bool:D $d = $file.IO.d();
    my Bool:D $f = $file.IO.f();
    my Bool:D $r = $file.IO.r();
    my Bool:D $w = $file.IO.w();
    my Bool:D $x = $file.IO.x();
    my PresenceHash:D $p = %(:$d, :$e, :$f, :$r, :$w, :$x);
}

multi method show(Str:D $file where *.so() --> PresenceHash:D)
{
    my Bool:D $e = False;
    my Bool:D $d = False;
    my Bool:D $f = False;
    my Bool:D $r = False;
    my Bool:D $w = False;
    my Bool:D $x = False;
    my PresenceHash:D $p = %(:$d, :$e, :$f, :$r, :$w, :$x);
}

sub exists-readable-dir(Str:D $dir where *.so() --> Bool:D) is export
{
    my PresenceHash:D $p = File::Presence.show($dir);
    my Bool:D $exists-readable-dir = $p<e> && $p<r> && $p<d>;
}

sub exists-readwriteable-dir(Str:D $dir where *.so() --> Bool:D) is export
{
    my PresenceHash:D $p = File::Presence.show($dir);
    my Bool:D $exists-readwriteable-dir = $p<e> && $p<r> && $p<w> && $p<d>;
}

sub exists-readable-file(Str:D $file --> Bool:D) is export
{
    my PresenceHash:D $p = File::Presence.show($file);
    my Bool:D $exists-readable-file = $p<e> && $p<r> && $p<f>;
}

sub exists-readwriteable-file(Str:D $file --> Bool:D) is export
{
    my PresenceHash:D $p = File::Presence.show($file);
    my Bool:D $exists-readwriteable-file = $p<e> && $p<r> && $p<w> && $p<f>;
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
