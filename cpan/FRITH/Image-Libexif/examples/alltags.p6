#!/usr/bin/env perl6

use lib 'lib';
use Image::Libexif :tagnames;
use Image::Libexif::Constants;

#| Prints all the EXIF tags
sub MAIN($file! where { .IO.f // die "file $file not found" })
{
  my Image::Libexif $e .= new: :$file;
  my @tags := $e.alltags: :tagdesc;
  say @tags».keys.flat.elems ~ ' tags found';
  for ^EXIF_IFD_COUNT -> $group {
    say "Group $group: " ~ «'Image info' 'Camera info' 'Shoot info' 'GPS info' 'Interoperability info'»[$group];
    for %(@tags[$group]).kv -> $k, @v {
      say "%tagnames{+$k}: @v[1] => @v[0]";
    }
  }
}
