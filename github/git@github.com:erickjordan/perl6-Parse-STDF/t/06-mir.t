use v6;
use Test;
use Parse::STDF;

plan 8;
try
{
  use-ok 'Parse::STDF';
  my $s = Parse::STDF.new( stdf => "t/data/test.stdf" );
  while $s.get_record
  {
    given ( $s.recname )
    {
      when "MIR"
      {
        ok 1, 'MIR record found in test.stdf';
        my $mir = $s.mir;
        ok $mir.defined, 'MIR object defined';
        is $mir.LOT_ID.cnstr, "LOT_ID", "LOT_ID is LOT_ID";
        like $mir.SETUP_T.ctime, /[1969|1970]/, "SETUP_T has year 1969 or 1970";
        like $mir.START_T.ctime, /[1969|1970]/, "START_T has year 1969 or 1970";
        is $mir.STAT_NUM, 2, "STAT_NUM is 2";
        is $mir.BURN_TIM, -1, "BURN_TIM is -1"; # BUG: #127210
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

