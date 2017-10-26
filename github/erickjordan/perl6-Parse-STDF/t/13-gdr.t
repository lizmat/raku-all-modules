use v6;
use Test;
use Parse::STDF;

plan 17;
try
{
  use-ok 'Parse::STDF';
  my $s = Parse::STDF.new( stdf => "t/data/gdr.stdf" );
  constant @FIELDS1 = 'RTA_HEADER', 'Date', '2/25/2015 12:07:00 PM';
  constant @FIELDS2 = 'RTA_SUMMARY', 0, 2, '(pad)', '(pad)', 'N/A', 'AVDD_1v0', 'Voltage Min', '1';

  my $gdr_count = 0;

  while $s.get_record
  {
    given ( $s.recname )
    {
      when "GDR"
      {
        $gdr_count++;
        if ( $gdr_count == 1 )
        {
          ok 1, 'GDR record found in gdr.stdf';
          my $gdr = $s.gdr;
          ok $gdr.defined, 'GDR object defined';
          is $gdr.FLD_CNT, 3, "FLD_CNT is 3";
          for @FIELDS1.kv -> $k, $v { is $gdr.field($k).data.Cn.cnstr, $v, "FIELDS1[$k] is $v"; }
        }
        if ( $gdr_count == 20 )
        {
          my $gdr = $s.gdr;
          is $gdr.FLD_CNT, 9, "FLD_CNT is 9";
          for @FIELDS2.kv -> $k, $v 
          { 
            my $field = $gdr.field($k);
            given ( $field.type )
            {
              when Parse::STDF::Native::GDR_B0 { ok 1, "FIELDS2[$k] is $v"; }
              when Parse::STDF::Native::GDR_Cn { is $field.data.Cn.cnstr, $v, "FIELDS2[$k] is $v"; }
              when Parse::STDF::Native::GDR_U1 { is $field.data.U1, $v, "FIELDS2[$k] is $v"; }
              when Parse::STDF::Native::GDR_U2 { is $field.data.U2, $v, "FIELDS2[$k] is $v"; }
            }
          }
          last;
        }
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
