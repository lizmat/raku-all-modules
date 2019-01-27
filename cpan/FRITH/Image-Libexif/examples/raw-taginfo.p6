#!/usr/bin/env perl6

use lib 'lib';
use Image::Libexif::Raw;
use Image::Libexif::Constants;
use NativeCall;

sub MAIN($file! where { .IO.f // die "file $file not found" })
{
  sub callback (ExifEntry $entry, Pointer $dummy) {
    -> ExifEntry $entry, Str $data {
      say "$data: ",
          $entry.tag.fmt('0x%04x ');
      my ($desc, $prev);
      for ExifIfd.enums.values.sort -> $id {
        my $out = exif_tag_get_description_in_ifd($entry.tag, $id);
        if $out.defined {
          if $prev.defined && $out eq $prev {
            last;
          } else {
            $desc ~= "$out\n";
            $prev = $out;
          }
        }
      }
      say "$desc";
    }($entry, $file);
  }

  my ExifData $exif = exif_data_new();
  $exif = exif_data_new_from_file($file);
  my Pointer $dummy .= new;
  for ^5 {
    my ExifContent $content = $exif.ifd[$_];
    exif_content_foreach_entry($content, &callback, $dummy);
  }
}
