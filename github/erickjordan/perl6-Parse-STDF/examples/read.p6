#!/usr/bin/env perl6

use v6;
use Parse::STDF;

sub MAIN( Str $stdf )
{
  try
  {
    my $s = Parse::STDF.new( stdf => $stdf );
    my $c = 0;
    while $s.get_record { $c++; }
    say "($c) records read.";
    say "Elapsed time: {now - INIT now} seconds";
    CATCH
    {
      when X::Parse::STDF { say $_.message; }
      default { say $_; }
    }
  }
}

