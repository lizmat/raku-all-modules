#!/usr/bin/env perl6

use Test;
use lib 'lib';
use Archive::Libarchive;
use Archive::Libarchive::Constants;

my $path = $*PROGRAM-NAME.subst(/ <-[/]>+$/, '');
my $filein = $path ~ 'test.tar.gz';
my Archive::Libarchive $a .= new:
    operation => LibarchiveExtract,
    file => $filein,
    flags => ARCHIVE_EXTRACT_TIME +| ARCHIVE_EXTRACT_PERM +| ARCHIVE_EXTRACT_ACL +| ARCHIVE_EXTRACT_FFLAGS;
is $a.WHAT, Archive::Libarchive, 'Create object for extract';
is $a.extract, True, 'Extract all files';
lives-ok { $a.close }, 'Close archive object';
'test1'.IO.unlink;
'test2'.IO.unlink;
'test3'.IO.unlink;
my Archive::Libarchive $a2 .= new:
    operation => LibarchiveExtract,
    file => $filein,
    flags => ARCHIVE_EXTRACT_TIME +| ARCHIVE_EXTRACT_PERM +| ARCHIVE_EXTRACT_ACL +| ARCHIVE_EXTRACT_FFLAGS;
$a2.extract: 't';
ok 't/test1'.IO.e && 't/test2'.IO.e && 't/test3'.IO.e, 'Extract into a specific directory';
$a2.close;
't/test1'.IO.unlink;
't/test2'.IO.unlink;
't/test3'.IO.unlink;
my Archive::Libarchive $a3 .= new:
    operation => LibarchiveExtract,
    file => $filein,
    flags => ARCHIVE_EXTRACT_TIME +| ARCHIVE_EXTRACT_PERM +| ARCHIVE_EXTRACT_ACL +| ARCHIVE_EXTRACT_FFLAGS;
$a3.extract(sub (Archive::Libarchive::Entry $e --> Bool) { $e.pathname eq 'test2' }, 't');
ok ! 't/test1'.IO.e && 't/test2'.IO.e && ! 't/test3'.IO.e, 'Extract one file';
't/test2'.IO.unlink;
$a3.close;

done-testing;
