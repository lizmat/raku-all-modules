#!/usr/bin/env perl6

use v6.c;
use RPi::Wiring::Pi;
use RPi::ButtonWatcher;

sub MAIN( *@pins ) {
    die if wiringPiSetup() != 0;

    # Takes WiringPi pin numbers.
    my $watcher = RPi::ButtonWatcher.new(
        pins => @pins,
        edge => FALLING,
        PUD => PULL_UP);

    $watcher.getSupply.tap( -> %v {
        my $e = %v<edge> == RISING ?? 'up' !! 'down';
        say "Pin: %v<pin>, Edge: $e";
    });
}

