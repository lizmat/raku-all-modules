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
          my $dtr = $s.dtr;
          say $s.dtr.TEXT_DAT.cnstr;
        }
        when "WIR"
        {
          my $wir = $s.wir;
          printf("Wafer-ID: %s\tWafer StartTime: %s\tSite Group: %d\n", 
                  $wir.WAFER_ID.cnstr, $wir.START_T.ctime, $wir.SITE_GRP);
        }
        when "PRR"
        {
          my $prr = $s.prr;
          printf("Device: %s\tBin: %2i\tStation: %2i\tSite: %3i\t(Software bin: %2i)\tWafer Coordinates: (%3i, %3i)\tElapsed test time (ms): %6i\n", 
                 $prr.PART_ID.cnstr, $prr.HARD_BIN, $prr.HEAD_NUM, $prr.SITE_NUM, 
                 $prr.SOFT_BIN, $prr.X_COORD, $prr.Y_COORD, $prr.TEST_T);
        }
        when "PTR"
        {
          my $ptr = $s.ptr;
          printf("%-8i %-50s %f\n", $ptr.TEST_NUM, $ptr.TEST_TXT.cnstr, $ptr.RESULT);
        }
        when "PIR"
        {
          my $pir = $s.pir;
          printf("\nHead: %d\tSite: %d\n\n", $pir.HEAD_NUM, $pir.SITE_NUM);
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

