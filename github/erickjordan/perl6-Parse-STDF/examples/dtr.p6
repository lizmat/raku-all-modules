#!/usr/bin/env perl6

use v6;
use Parse::STDF;

sub MAIN( Str $stdf )
{
  try
  {
    my $s = Parse::STDF.new( stdf => $stdf );
    while $s.get_record
    {
      given ( $s.recname )
      {
        when "DTR"
        {
          printf("%s\n", $s.dtr.TEXT_DAT.cnstr);
        }
        default {}
      }
    }
    CATCH
    {
      when X::Parse::STDF { say $_.message; }
      default { say $_; }
    }
  }
}

