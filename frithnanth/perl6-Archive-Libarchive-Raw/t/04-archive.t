#!/usr/bin/env perl6

use Test;
use lib 'lib';
use Archive::Libarchive::Raw;
use Archive::Libarchive::Constants;

my archive $a = archive_write_new;
ok {defined $a}, 'initialization';

is archive_write_add_filter_gzip($a), ARCHIVE_OK, 'use gzip filter';
is archive_write_set_format_pax_restricted($a), ARCHIVE_OK, 'use pax restricted archive format';
my $fileout = './test.tar.gz';
archive_write_open_filename($a, $fileout);
my archive_entry $entry = archive_entry_new;
ok {defined $entry}, 'create entry object';
my $filein = 't/00-use.t';
archive_entry_set_pathname($entry, $filein);
archive_entry_set_size($entry, $filein.IO.s);
archive_entry_set_filetype($entry, AE_IFREG);
archive_entry_set_perm($entry, 0o755);
is archive_write_header($a, $entry), ARCHIVE_OK, 'write header';
my $fh = open $filein, :r;
my $buffer = $fh.read(8192);
is archive_write_data($a, $buffer, $buffer.bytes), $filein.IO.s, 'write data';
$fh.close;
archive_entry_free($entry);
is archive_write_close($a), ARCHIVE_OK, 'close file';
is archive_write_free($a), ARCHIVE_OK, 'free write buffers';

my archive $a2 = archive_read_new();
$buffer = slurp $fileout, :bin;
is archive_read_support_filter_gzip($a2), ARCHIVE_OK, 'use gzip compression';
is archive_read_support_format_tar($a2), ARCHIVE_OK, 'use tar file format';
is archive_read_open_memory($a2, $buffer, $fileout.IO.s), ARCHIVE_OK, 'read from memory';
is archive_read_next_header($a2, $entry), ARCHIVE_OK, 'read header entry from memory';
is archive_entry_pathname($entry), $filein, 'find filename';
archive_read_free($a2);

$fileout.IO.unlink;

done-testing;
