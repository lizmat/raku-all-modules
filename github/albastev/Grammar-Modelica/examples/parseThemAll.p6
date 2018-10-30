#!perl6

use v6;
use Test;
use lib '../lib';
use Grammar::Modelica;
# use Grammar::Tracer;


plan 313;

sub light($file) {
  my $fh = open $file, :r;
  my $contents = $fh.slurp-rest;
  $fh.close;

  my $match = Grammar::Modelica.parse($contents);
  say $file;
  ok $match;
  #say $match;
}

sub MAIN($modelica-dir) {
    say "directory: $modelica-dir";
    die "Can't find directory" if ! $modelica-dir.IO.d;
    
    # https://docs.perl6.org/routine/dir
    my @stack = $modelica-dir.IO;
    my @files;
    while @stack { 
      for @stack.pop.dir -> $path { 
        @files.push($path) if $path.f && $path.extension.lc eq 'mo'; 
        @stack.push: $path if $path.d;
      }
    }
    @files.race.map({light($_)});
}
