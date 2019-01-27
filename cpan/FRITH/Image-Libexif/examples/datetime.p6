#!/usr/bin/env perl6

use Concurrent::File::Find;
use Image::Libexif;
use Image::Libexif::Constants;

#| This program displays the EXIF date and time for every file in a directory tree
sub MAIN($dir where {.IO.d // die "$dir not found"})
{
  my @files := find $dir, :extension('jpg'), :exclude-dir('thumbnails') :file, :!directory;
  @files.race.map: -> $file {
      my Image::Libexif $e .= new: :file($file);
      try say "$file " ~ $e.lookup(EXIF_TAG_DATE_TIME_ORIGINAL); # don't die if no EXIF is present
      $e.close;
    }
}
