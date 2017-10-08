#!/usr/bin/env perl6

use lib 'lib';
use Archive::Libarchive;

# Ask explicitly for a tar v.7 format and no filter

sub MAIN($fileo! where { ! .IO.f || die "file '$fileo' already present" },
         *@filei where { $_.all ~~ .IO.f || die "One of ( $_ ) not found" } )
{
  my Archive::Libarchive $a .= new: operation => LibarchiveWrite, file => $fileo, format => 'v7tar', filters => ['none'];
  for @filei -> $file {
    try {
      $a.write-header($file, uname => 'user1', gname => 'group1');
      $a.write-data($file);
      CATCH {
        default { .Str.say }
      }
    }
  }
  $a.close;
}
