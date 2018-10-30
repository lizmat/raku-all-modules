#!/usr/bin/env perl6

use v6;
use Parse::STDF;

sub MAIN(Str $stdf, Bool :$verbose = False )
{
  try
  {
    my $s = Parse::STDF.new( stdf => $stdf );
    my %bcount;
    my %btime;
    while $s.get_record
    {
      given ( $s.recname )
      {
        when "PRR"
        {
          my $prr = $s.prr; 
          if ( $verbose )
          {
            printf("Part Id: %s\tBin: %2i\tHead: %2i\tSite: %3i\t(Software bin: %2i)\tElapsed test time(ms): %6i\n",
                    $prr.PART_ID.cnstr, $prr.HARD_BIN, $prr.HEAD_NUM, $prr.SITE_NUM, $prr.SOFT_BIN, $prr.TEST_T);
          }
          %bcount{$prr.HARD_BIN}++;
          %btime{$prr.HARD_BIN} += $prr.TEST_T;
        }
        default {}
      }
    }
    say "" if ( $verbose ); 
    for %bcount.keys.sort -> $bin 
    {
      printf("Bin: %2d\tCount: %5d\tAverage Test Time: %10.2f (ms)\n", $bin, %bcount{$bin}, %btime{$bin}/%bcount{$bin} );
    }
    CATCH
    {
      when X::Parse::STDF { say $_.message; }
      default { say $_; }
    }
  }
}

