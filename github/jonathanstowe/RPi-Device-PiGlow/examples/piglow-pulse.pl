#!/usr/bin/env perl6

use RPi::Device::PiGlow;

my $pg = RPi::Device::PiGlow.new();

my @rings = (0 .. 5);

my @values = ( 0 .. 255);

$pg.enable-output();
$pg.enable-all-leds();

signal(SIGINT).tap({ say "Reset"; $pg.reset(); exit; });

loop {
    for @rings -> $ring {
        my $value = @values.shift;
        say "Setting ring $ring to $value";
        $pg.set-ring($ring, $value);
        @values.push($value);
    }
    $pg.update();
    sleep 1;
}

# vim: expandtab shiftwidth=4 ft=perl6
