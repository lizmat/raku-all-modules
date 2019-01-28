use v6.c;
use Test;
use P5seek;

plan 11;

ok defined(::('&seek')),      'is &seek imported?';
ok !defined(P5seek::{'&seek'}), 'is &seek externally NOT accessible?';

is SEEK_SET, 0, 'did we get SEEK_SET';
is SEEK_CUR, 1, 'did we get SEEK_CUR';
is SEEK_END, 2, 'did we get SEEK_END';

my $handle = open($?FILE, :r);
for 0, 1, 2, SEEK_SET, SEEK_CUR, SEEK_END -> $whence {
    ok seek( $handle, 42, $whence), "did a seek with $whence work out?";
}

# vim: ft=perl6 expandtab sw=4
