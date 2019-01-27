#!/usr/bin/env perl6

use v6;
use MONKEY-SEE-NO-EVAL;
use Pod::To::HTML;

sub MAIN( $file = "../../README.pod6" ) {
    my $file-content = $file.IO.slurp;
    die "No pod here" if not $file-content ~~ /\=begin \s+ pod/;
    my $pod;
    try {
	$pod = EVAL($file-content ~ "\n\$=pod");
    };
    die "Pod fails: $!" if $!;
    my $result = pod2html( $pod, templates => '.' );
    say $result;
}
