use v6;
use Test;
use Parse::STDF;

plan 8;
try
{
  use-ok 'Parse::STDF';
  my $s = Parse::STDF.new( stdf => "t/data/test.stdf" );
  constant @SITE_NUM = <5 10 15 20>;

  while $s.get_record
  {
    given ( $s.recname )
    {
      when "SDR"
      {
        ok 1, 'SDR record found in test.stdf';
        my $sdr = $s.sdr;
        ok $sdr.defined, 'SDR object defined';
        is $sdr.SITE_CNT, 4, "SITE_CNT is 4";
        my @sites = $sdr.SITE_NUM.array($sdr.SITE_CNT);
        for $sdr.SITE_NUM.array($sdr.SITE_CNT).kv -> $k, $v { is @SITE_NUM[$k], $v,  "SITE_NUM[$k] is $v"; }
        last;
      }
    }
  }
  CATCH
  {
    when X::Parse::STDF::LibraryMissing { 
      diag $_.message; 
      # skip-rest('missing prereq');
    }
  }
}

