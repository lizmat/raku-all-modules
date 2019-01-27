#!/usr/bin/env perl6

use lib 'lib';
use Image::Libexif::Raw;
use Image::Libexif::Constants;
use NativeHelpers::Blob;

# Perl6 rendition of this C program:
# https://github.com/libexif/libexif/blob/master/contrib/examples/thumbnail.c

#| This program extracts an EXIF thumbnail from an image and saves it into a new file (in the same directory as the original).
sub MAIN($file! where { .IO.f // die "file '$file' not found" })
{
  my $l = exif_loader_new() // die ’Can't create an exif loader‘;
  # Load the EXIF data from the image file
  exif_loader_write_file($l, $file);
  # Get the EXIF data
  my $ed = exif_loader_get_data($l) // die ’Can't get the exif data‘;
  # The loader is no longer needed--free it
  exif_loader_unref($l);
  $l = Nil;
  if $ed.data && $ed.size {
    my $thumb-name = $file;
    $thumb-name ~~ s/\.jpg/_thumb.jpg/;
    my $data = blob-from-pointer($ed.data, :elems($ed.size), :type(Blob));
    spurt $thumb-name, $data, :bin;
  } else {
    say "No EXIF thumbnail in file $file";
  }
  # Free the EXIF data
  exif_data_unref($ed);
}
