use v6;
use Test;
use Parse::STDF;

plan 4;
try
{
  use-ok 'Parse::STDF';
  my $s = Parse::STDF.new( stdf => "t/data/test.stdf" );
  $s.get_record;
  is $s.recname, "FAR", 'FAR record found in test.stdf';
  my $far = $s.far;
  ok $far.defined, 'FAR object defined';
  is $far.CPU_TYPE, 2, 'CPU_TYPE is 2';
  CATCH
  {
    when X::Parse::STDF::LibraryMissing { 
      diag $_.message; 
      # skip-rest('missing prereq');
    }
  }
}
