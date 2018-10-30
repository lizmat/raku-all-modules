use v6;
use Test;
use Parse::STDF;

plan 2;
try
{
  use-ok 'Parse::STDF';
  my $s = Parse::STDF.new( stdf => "t/data/test.stdf" );
  is $s.ver, 4, 'STDF version is 4';
  CATCH
  {
    when X::Parse::STDF::LibraryMissing { 
      diag $_.message; 
      # skip-rest('missing prereq');
    }
  }
}
