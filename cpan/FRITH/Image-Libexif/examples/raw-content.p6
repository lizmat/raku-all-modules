#!/usr/bin/env perl6

use lib 'lib';
use Image::Libexif::Raw;
use NativeCall;

#| This program dumps the EXIF content of its argument
sub MAIN($file! where { .IO.f // die "file $file not found" })
{
  my ExifData $exif = exif_data_new();
  $exif = exif_data_new_from_file($file);
  my Pointer $dummy .= new;
  exif_data_foreach_content($exif,
    sub (ExifContent $content, Pointer $dummy) {
      -> ExifContent $content {
        exif_content_dump($content, 0);
      }($content);
    },
    $dummy);
}
