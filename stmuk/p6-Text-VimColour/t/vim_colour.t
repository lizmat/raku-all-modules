#!/usr/bin/env perl6

use v6;

BEGIN { @*INC.unshift( 'lib' ) }

use Test;
use Text::VimColour;

plan 5;

my $lang = 'perl6';
my $in = 't/vim_colour.t';
my $out = $?FILE.IO.dirname ~ $*SPEC.dir-sep ~ 'index.html';

unlink $out if $out.IO.f;

Text::VimColour.new( :$lang, :$in, :$out ) ;
ok $out.IO.e && slurp($out) ~~ /vimCodeElement/, 'found vimCodeElement';

my $c = Text::VimColour.new(:$lang, :$in);
ok $c.html ~~ /vimCodeElement/, 'to temp file';

my $x = Text::VimColour.new(:lang('perl6'), code => 'use v6; BEGIN {}; ');
ok $x.html-full-page ~~ /vimCodeElement/, 'from string';

ok $x.html ~~ /vimCodeElement/, 'body';

ok $x.css ~~ /background/, 'css';


