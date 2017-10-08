#!/usr/bin/env perl6

use lib 'lib';
use Archive::Libarchive;

sub MAIN(Str :$file! where { .IO.f // die "file '$file' not found" })
{
  my $buffer = slurp $file, :bin;
  my $a = Archive::Libarchive.new: operation => LibarchiveRead, file => $buffer;
  my Archive::Libarchive::Entry $e .= new;
  while $a.next-header($e) {
    $e.pathname.say;
    $a.data-skip;
  }
  $a.close;
}
