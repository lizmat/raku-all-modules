#!/usr/bin/env perl6

use v6;
use Parse::STDF;

sub MAIN( Str $stdf )
{
  try
  {
    my $s = Parse::STDF.new( stdf => $stdf );
    my %recs;
    while $s.get_record { %recs{$s.recname}++; }
    my $total = 0;
    for %recs.sort(*.key)>>.kv -> ($key,$val) { $total += $val; say "$key: $val"; }
    say "TOTAL: $total";
    CATCH
    {
      when X::Parse::STDF { say $_.message; }
      default { say $_; }
    }
  }
}

