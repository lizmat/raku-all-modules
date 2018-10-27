use v6;
use Test;
use Parse::STDF;

plan 41;
try
{
  use-ok 'Parse::STDF';
  my $s = Parse::STDF.new( stdf => "t/data/test.stdf" );
  constant @RTN_STAT = <10 11 12 13 14 15 1 2 3 4 5 6 7 8 9>;
  constant @RTN_RSLT = <1.2 2.3 3.4 4.5 5.6 6.7>;
  constant @RTN_INDX = <1 3 5 7 9 11 13 15 17 19 21 23 25 27 29>;

  while $s.get_record
  {
    given ( $s.recname )
    {
      when "MPR"
      {
        ok 1, 'MPR record found in test.stdf';
        my $mpr = $s.mpr;
        ok $mpr.defined, 'MPR object defined';
        is $mpr.RTN_ICNT, 15, "RTN_ICNT is 15";
        for $mpr.RTN_STAT.array($mpr.RTN_ICNT).kv -> $k, $v { is @RTN_STAT[$k], $v, "RTN_STAT[$k] is $v"; }
        is $mpr.RSLT_CNT, 6, "RSLT_CNT is 6";
        for $mpr.RTN_RSLT.array($mpr.RSLT_CNT).kv -> $k, $v { is-approx @RTN_RSLT[$k], $v, "RTN_RSLT[$k] is $v"; }
        for $mpr.RTN_INDX.array($mpr.RTN_ICNT).kv -> $k, $v { is @RTN_INDX[$k], $v, "RTN_INDX[$k] is $v"; }
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
