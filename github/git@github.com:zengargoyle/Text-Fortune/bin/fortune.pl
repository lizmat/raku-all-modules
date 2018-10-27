#!/usr/bin/env perl6

use v6;
use File::Find;
use Text::Fortune;

sub MAIN( Bool :$offensive, Str :$dir = '/usr/share/games/fortunes') {
  my @files := find(
    dir => $dir,
    type => 'file',
    name => rx/<!after \.dat>$/,
    :!recursive,  #= :recursive if you want offensive fortunes
  );

  my $f = Text::Fortune::File.new( path => @files.pick );
  print $f.random;
}
