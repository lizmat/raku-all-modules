#!/usr/bin/env perl6
use v6;
use Bench;

use lib 'lib';
use Search::Dict;

my $dict = '/usr/share/dict/words';
my $needle-count = 10;
my $rounds = 1000;
my @block-sizes = 1, 64, 128, 512, 1024;

dd :$needle-count, :$rounds, :@block-sizes, :$dict;

my @needles = $dict.IO.lines.pick($needle-count);

my %tests = do for @block-sizes -> $block-size {
 $block-size => sub {
   my &l = search-dict($dict, :$block-size);
   my @f = @needles.map({l($_)});
   note "mismatch" unless @f eqv @needles;
   1;
 }
};

my $b = Bench.new;
$b.cmpthese( $rounds, {
  %tests
});

