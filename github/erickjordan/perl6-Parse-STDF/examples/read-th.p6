#!/usr/bin/env perl6

use v6;
use Parse::STDF;

sub read ( Str $stdf)
{
  try
  {
    my $s = Parse::STDF.new( stdf => $stdf );
    my $c = 0;
    while $s.get_record { $c++; }
    say "($c) records read.";
    CATCH
    {
      when X::Parse::STDF { say $_.message; }
      default { say $_; }
    }
  }
}


sub MAIN( Str $stdf )
{
  my $p1 = Promise.start( { read($stdf) } );
  my $p2 = Promise.start( { read($stdf) } );
  $p1.result;
  $p2.result;
  say "Elapsed tim: {now - INIT now} seconds";
}

