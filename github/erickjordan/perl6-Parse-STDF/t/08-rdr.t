use v6;
use Test;
use Parse::STDF;

plan 14;
try
{
  use-ok 'Parse::STDF';
  my $s = Parse::STDF.new( stdf => "t/data/test.stdf" );
  constant @RTST_BIN = <2 4 6 8 10 12 14 16 18 20>;

  while $s.get_record
  {
    given ( $s.recname )
    {
      when "RDR"
      {
        ok 1, 'RDR record found in test.stdf';
        my $rdr = $s.rdr;
        ok $rdr.defined, 'RDR object defined';
        is $rdr.NUM_BINS, 10, "NUM_BINS is 10";
        for $rdr.RTST_BIN.array($rdr.NUM_BINS).kv -> $k, $v { is @RTST_BIN[$k], $v, "RTST_BIN[$k] is $v"; }
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
