#!/usr/bin/env perl6

use v6;
use Parse::STDF;

sub MAIN( Str $stdf )
{
  try
  {
    my $s = Parse::STDF.new( stdf => $stdf );
    printf("STDF Version: %d\n", $s.ver);
    CATCH
    {
      when X::Parse::STDF { say $_.message; }
      default { say $_; }
    }
  }
}

