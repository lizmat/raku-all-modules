#!/usr/bin/env perl6

use lib 'lib';
use Archive::Libarchive::Raw;
use Archive::Libarchive::Constants;

sub archiver(@filei, $fileo)
{
  my archive $a = archive_write_new;
  archive_write_add_filter_gzip($a);
  archive_write_set_format_pax_restricted($a);
  # or
  # archive_write_set_format_filter_by_ext $a, $fileo;
  archive_write_open_filename($a, $fileo);
  for @filei -> $file {
    my archive_entry $entry = archive_entry_new;
    archive_entry_set_pathname($entry, $file);
    archive_entry_set_size($entry, $file.IO.s);
    archive_entry_set_filetype($entry, AE_IFREG);
    archive_entry_set_perm($entry, 0o644);
    archive_write_header($a, $entry);
    my $fh = open $file, :r;
    while my $buffer = $fh.read(8192) {
      archive_write_data($a, $buffer, $buffer.bytes);
    }
    $fh.close;
    archive_entry_free($entry);
  }
  archive_write_close($a);
  archive_write_free($a);
}

sub MAIN($fileo! where { ! .IO.f || die "file '$fileo' already present" },
         *@filei where { $_.all ~~ .IO.f || die "One of ( $_ ) not found" } )
{
  archiver(@filei, $fileo);
}
