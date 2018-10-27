use v6;
use Test;
use Parse::STDF;

plan 40;
try
{
  use-ok 'Parse::STDF';
  my $s = Parse::STDF.new( stdf => "t/data/test.stdf" );
  constant @GRP_INDX = <2 4 6 8 10 12 2041 3041 4041 5041 6041 7041>;
  constant @GRP_RADX = <0 2 8 10 16 20 221 222 223 224 225 226>;
  constant @PGM_CHAR = <A B C D E F 01 012 0123 01234 012345 0123456>;

  while $s.get_record
  {
    given ( $s.recname )
    {
      when "PLR"
      {
        ok 1, 'PLR record found in test.stdf';
        my $plr = $s.plr;
        ok $plr.defined, 'PLR object defined';
        is $plr.GRP_CNT, 12, "GRP_CNT is 12";
        for $plr.GRP_INDX.array($plr.GRP_CNT).kv -> $k, $v { is @GRP_INDX[$k], $v, "GRP_INDX[$k] is $v"; }
        for $plr.GRP_RADX.array($plr.GRP_CNT).kv -> $k, $v { is @GRP_RADX[$k], $v, "GRP_RADX[$k] is $v"; }
        for $plr.PGM_CHAR.array($plr.GRP_CNT).kv -> $k, $v { is @PGM_CHAR[$k], $v.cnstr, "PGM_CHAR[$k] is " ~ $v.cnstr; }
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
