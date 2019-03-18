use v6.c;
use Test;
use DirHandle;
%*ENV<RAKUDO_NO_DEPRECATIONS> = True;

plan 11;

my $dir = $?FILE.IO.parent.IO.absolute;
my $dh = DirHandle.new($dir);
is $dh.^name, 'DirHandle', 'did we get a DirHandle';
is $dh.tell, 0, 'did the tell work';
is ~$dh, $dir, 'does it stringify correctly';

my @files;
@files.push($dh.read) for ^4;
is $dh.read, Nil, 'end reached';

my $expected = '. .. 01-basic.t opendir.t';
is @files.sort, $expected, 'did we get all entries';

ok $dh.rewind, 'did the rewind work';
my @entries;
@entries.push($_) while $dh.read(:void);
is @entries.sort, $expected, 'did we get all entries';

ok $dh.seek(0), 'did the seekdir work';
@entries = ();
@entries.push($_) while $dh.read(Mu);
is @entries.sort, $expected, 'did we get all entries';

is $dh.tell, 4, 'did the telldir work';
ok $dh.close, 'did the closedir work';

# vim: ft=perl6 expandtab sw=4
