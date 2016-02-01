unit module Acme::Scrub:ver<0.2.0>:auth<github:thundergnat>;

my @socks = '﻿​'.comb;
my %pants = @socks.pairs.invert;
my $suds  = ' for REALLY clean code.';

my $wash = $*PROGRAM-NAME.IO.slurp.subst( /(.*"use Acme::Scrub;") " #"?/, '' );
my $soak = $0;
$wash .= subst(/$suds.*$/, '');
if $wash ~~ /\w/ {
    my $soap = Buf.new($wash.encode('UTF-8'));
    $*PROGRAM-NAME.IO.spurt: [~] $soak, ' #',
      @socks[$soap[*]».fmt("%08b").join.comb].join, $suds;
} else {
    use MONKEY-SEE-NO-EVAL;
    EVAL Blob.new( map { :2(%pants{$_.comb}.join) },
    $wash.comb(8)).decode;
}
