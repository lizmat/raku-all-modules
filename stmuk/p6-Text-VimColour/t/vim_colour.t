#!/usr/bin/env perl6

use v6;

BEGIN { @*INC.unshift( 'lib' ) }

use Test;
use Text::VimColour;

plan 1;

my $lang = 'perl6';
my $in = 't/vim_colour.t';
my $out = 't/index.html';

Text::VimColour.new( :$lang, :$in, :$out ) ;

ok slurp($out) ~~ /vimCodeElement/, 'found vimCodeElement';
