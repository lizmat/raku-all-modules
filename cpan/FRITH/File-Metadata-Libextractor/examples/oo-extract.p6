#!/usr/bin/env perl6

use lib 'lib';
use File::Metadata::Libextractor;

#| This program extracts all the information about a file
sub MAIN($file! where { .IO.f // die "file '$file' not found" })
{
  my File::Metadata::Libextractor $e .= new;
  my @info = $e.extract($file);
  for @info -> %record {
    for %record.kv -> $k, $v {
      say "$k: $v"
    }
    say '-' x 50;
  }
}
