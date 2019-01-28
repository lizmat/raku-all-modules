use v6.c;
use Test;
use P5readlink;

plan 10;

ok defined(::('&readlink')),            'is &readlink imported?';
ok !defined(P5readlink::{'&readlink'}), '&readlink externally NOT accessible?';

is readlink("doesnotexist"), Nil, 'did we get a Nil on it non-existing?';
is readlink($?FILE), Nil, 'did we get a Nil on it not being a symlink?';

my $symlink = $?FILE.IO.parent.IO.child("symlink");
unlink $symlink;
nok $symlink.e, 'is there no "symlink" anymore?';

LEAVE unlink $symlink;
ok symlink($?FILE, $symlink), 'create the symlink';

is readlink($symlink), $?FILE, 'did we get this file back as symlink on it?';
given $symlink {
    is readlink, $?FILE, 'did we get this file back as symlink on $_?';
}

given "doesnotexist" {
    is readlink, Nil, 'did we get a Nil on $_ non-existing?';
}
given $?FILE {
    is readlink($?FILE), Nil, 'did we get a Nil on $_ not being a symlink?';
}

# vim: ft=perl6 expandtab sw=4
