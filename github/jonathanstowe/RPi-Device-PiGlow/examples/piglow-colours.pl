#!/usr/bin/env perl6

use RPi::Device::PiGlow;

my $pg = RPi::Device::PiGlow.new();

my @colours = $pg.colours();

$pg.enable-output();
$pg.enable-all-leds();

signal(SIGINT).tap({ say "Reset"; $pg.reset(); exit; });

loop {
    my $on-colour = @colours.shift;
    say "Writing colour " ~ $on-colour;
    $pg.set-colour($on-colour, 0xFF);
    for @colours -> $off-colour {
       $pg.set-colour($off-colour, 0x00);
    }
    
    $pg.update();
    @colours.push($on-colour);
    sleep 1;
}

# vim: expandtab shiftwidth=4 ft=perl6
