#!/usr/bin/env perl6

use Test;
use lib 'lib';
use Archive::Libarchive::Raw;
use Archive::Libarchive::Constants;

my archive $a = archive_read_new();
ok {defined $a}, 'initialization';
# from file
is archive_read_support_filter_all($a), ARCHIVE_OK, 'use any compression filter';
is archive_read_support_format_all($a), ARCHIVE_OK, 'use any file format';
my $path = $*PROGRAM-NAME.subst(/ <-[/]>+$/, '');
# nonexistent file
is archive_read_open_filename($a, $path ~ 'nofile', 10240), ARCHIVE_FATAL, 'read from nonexistent file';
is archive_error_string($a), "Failed to open 't/nofile'", 'error string';
# ARCHIVE_FATAL makes the archive handler unusable
$a = archive_read_new();
archive_read_support_filter_all($a);
archive_read_support_format_all($a);
# read from file
my $file = $path ~ "testdata.tar.gz";
is archive_read_open_filename($a, $file, 10240), ARCHIVE_OK, 'read from file';
is archive_errno($a), 0, 'errno';
my archive_entry $entry .= new;
ok {defined $entry}, 'create entry object';
is archive_read_next_header($a, $entry), ARCHIVE_OK, 'read header entry 1 from file';
is archive_format_name($a), 'GNU tar format', 'read format name';
is archive_format($a), ARCHIVE_FORMAT_TAR_GNUTAR, 'read format number';
is archive_entry_pathname($entry), 'datafile1', 'read file 1 name';
is archive_read_data_skip($a), ARCHIVE_OK, 'skip file 1 data';
is archive_read_next_header($a, $entry), ARCHIVE_OK, 'read header entry 2 from file';
is archive_entry_pathname($entry), 'datafile2', 'read file 2 name';
is archive_file_count($a), 2, 'archive file count';
is archive_read_free($a), ARCHIVE_OK, 'free internal data structures';
# read from memory
my archive $a2 = archive_read_new();
my $buffer = slurp $file, :bin;
is archive_read_support_filter_gzip($a2), ARCHIVE_OK, 'use gzip compression';
is archive_read_support_format_tar($a2), ARCHIVE_OK, 'use tar file format';
is archive_read_open_memory($a2, $buffer, $file.IO.s), ARCHIVE_OK, 'read from memory';
is archive_read_next_header($a2, $entry), ARCHIVE_OK, 'read header entry from memory';
archive_read_free($a2);

done-testing;
