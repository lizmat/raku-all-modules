use v6.c;
use Test;
use P5opendir;

plan 14;

my $dir = $?FILE.IO.parent.IO.absolute;
ok opendir(my $handle, $dir), 'did we return ok for opening?';
ok $handle, 'did we get an instantiated object?';
is $handle.^name, 'DIRHANDLE', 'did we get a DIRHANDLE';
is telldir($handle), 0, 'did the telldir work';

my @files;
@files.push(readdir($handle, :scalar)) for ^4;
is readdir($handle, :scalar), Nil, 'end reached';

my $expected = '. .. 01-basic.t 02-basic.t';
is @files.sort, $expected, 'did we get all entries';

ok rewinddir($handle), 'did the rewinddir work';
my @entries;
@entries.push($_) while readdir($handle, :void);
is @entries.sort, $expected, 'did we get all entries';

ok seekdir($handle,0), 'did the seekdir work';
@entries = ();
@entries.push($_) while readdir($handle, :void);
is @entries.sort, $expected, 'did we get all entries';

ok rewinddir($handle), 'did the rewinddir work';
@entries = readdir($handle);
is @entries.sort, $expected, 'did we get all entries';

is telldir($handle), 4, 'did the telldir work';
ok closedir($handle), 'did the closedir work';

# vim: ft=perl6 expandtab sw=4
