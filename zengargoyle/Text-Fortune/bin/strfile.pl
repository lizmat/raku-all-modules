#!/usr/bin/env perl6
# vim: ft=perl6

use v6;
use Text::Fortune;

sub MAIN(
  Str $sourcefile as IO,
  Str $datafile as IO = $sourcefile ~ '.dat',
  Bool :$rotated = False,
  Bool :$quiet = False,
  Str :$delimiter where { *.chars == 1 & *.ord < 127 } = '%',
) {

  my $index = Text::Fortune::Index.new( :$rotated, :$delimiter )\
    .load-fortune( $sourcefile.IO.path );

  CATCH {
    when X::Index::NotFound {
      note "Could not open '{$sourcefile.IO.path}'";
      exit;
    }
  }

  $datafile.IO.open(:w).write( $index.Buf );
  
  unless $quiet {
    say qq ("{$sourcefile.IO.path}" created);
    say qq (There was {$index.count} string);
    say qq (Longest string: {$index.longest} bytes);
    say qq (Shorest string: {$index.shortest} bytes);
  }
}
