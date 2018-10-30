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
        when "SDR"
        {
          my $sdr = $s.sdr;
          printf("\tHEAD_NUM: %d\n", $sdr.HEAD_NUM);
          printf("\tSITE_GRP: %d\n", $sdr.SITE_GRP);
          printf("\tSITE_CNT: %d\n", $sdr.SITE_CNT);
          print "\tSITE_NUM: ", $sdr.SITE_NUM.array($sdr.SITE_CNT), "\n";
          printf("\tHAND_TYP: %s\n", $sdr.HAND_TYP.cnstr);
          printf("\tHAND_ID: %s\n", $sdr.HAND_ID.cnstr);
          printf("\tCARD_TYP: %s\n", $sdr.CARD_TYP.cnstr);
          printf("\tCARD_ID: %s\n", $sdr.CARD_ID.cnstr);
          printf("\tLOAD_TYP: %s\n", $sdr.LOAD_TYP.cnstr);
          printf("\tLOAD_ID: %s\n", $sdr.LOAD_ID.cnstr);
          printf("\tDIB_TYP: %s\n", $sdr.DIB_TYP.cnstr);
          printf("\tDIB_ID: %s\n", $sdr.DIB_ID.cnstr);
          printf("\tCABL_TYP: %s\n", $sdr.CABL_TYP.cnstr);
          printf("\tCABL_ID: %s\n", $sdr.CABL_ID.cnstr);
          printf("\tCONT_TYP: %s\n", $sdr.CONT_TYP.cnstr);
          printf("\tCONT_ID: %s\n", $sdr.CONT_ID.cnstr);
          printf("\tLASR_TYP: %s\n", $sdr.LASR_TYP.cnstr);
          printf("\tLASR_ID: %s\n", $sdr.LASR_ID.cnstr);
          printf("\tEXTR_TYP: %s\n", $sdr.EXTR_TYP.cnstr);
          printf("\tEXTR_ID: %s\n", $sdr.EXTR_ID.cnstr);
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

