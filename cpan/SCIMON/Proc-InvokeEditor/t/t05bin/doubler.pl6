#!/usr/bin/env perl6

use v6c;

sub MAIN( $file ) {
    my $input = $file.IO.slurp;

    $file.IO.spurt( $input ~ $input );
}
