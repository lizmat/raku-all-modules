#!/usr/bin/env perl6

use lib 'lib';
use Image::Libexif;
use Image::Libexif::Constants;

sub MAIN($file! where { .IO.f // die "file $file not found" })
{
  my Image::Libexif $exif .= new(:$file);
  say $exif.lookup(EXIF_TAG_MAKE);
}
