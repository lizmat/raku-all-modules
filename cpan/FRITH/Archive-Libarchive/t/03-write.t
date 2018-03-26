#!/usr/bin/env perl6

use Test;
use lib 'lib';
use Archive::Libarchive;

my Archive::Libarchive $a .= new: operation => LibarchiveWrite;
is $a.WHAT, Archive::Libarchive, 'Create object for writing';
my $path = $*PROGRAM-NAME.subst(/ <-[/]>+$/, '');
throws-like
  { $a.open: $path ~ 'test.tar.gz' },
  X::Libarchive,
  message => /'File already present'/,
  'Open file fails';
my $fileout = $path ~ 'test1.tar.gz';
$fileout.IO.unlink if $fileout.IO.e;
lives-ok { $a.open: $fileout, format => 'gnutar', filters => ['gzip'] }, 'Open file succeedes';
$a.close;
$fileout.IO.unlink;
my Archive::Libarchive $aa .= new:
  operation => LibarchiveWrite,
  file => $fileout,
  format => 'gnutar',
  filters => ['gzip'];
is $aa.WHAT, Archive::Libarchive, 'Create object and file for writing';
$aa.close;
my Archive::Libarchive $ao .= new:
  operation => LibarchiveOverwrite,
  file => $fileout,
  format => 'gnutar',
  filters => ['gzip'];
is $ao.WHAT, Archive::Libarchive, 'Create object and file for overwriting';
is $ao.write-header($*PROGRAM-NAME), True, 'Write header';
is $ao.write-data($*PROGRAM-NAME), True, 'Write data';
lives-ok { $ao.close }, 'Close archive';
$fileout.IO.unlink;

done-testing;
