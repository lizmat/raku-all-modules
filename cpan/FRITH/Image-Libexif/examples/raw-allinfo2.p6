#!/usr/bin/env perl6

use lib 'lib';
use Image::Libexif::Raw;
use Image::Libexif::Constants;
use NativeCall;

sub MAIN($file! where { .IO.f // die "file $file not found" })
{
  sub callback (ExifEntry $entry, Pointer $dummy) {
    -> ExifEntry $entry, Str $data {
      my Buf $buf .= allocate: 100, 0;
      say "$data: ",
          $entry.tag.fmt('0x%04x '),
          exif_entry_get_value($entry, $buf, 100);
    }($entry, $file);
  }

  my ExifData $exif = exif_data_new();
  $exif = exif_data_new_from_file($file);
  my Pointer $dummy .= new;
  for ^5 {
    my ExifContent $content = $exif.ifd[$_];
    exif_content_foreach_entry($content, &callback, $dummy);
  }

  my $mnote = exif_data_get_mnote_data($exif);
  my $notes = exif_mnote_data_count($mnote);
  my $val = Buf.new(1..1024);
  for 1..$notes -> $note {
    say "$file: ",
      exif_mnote_data_get_description($mnote, $note) // ' ', ' ',
      exif_mnote_data_get_name($mnote, $note) // ' ', ' ',
      exif_mnote_data_get_title($mnote, $note) // ' ', ' ',
      exif_mnote_data_get_value($mnote, $note, $val, 1024);
  }
}
