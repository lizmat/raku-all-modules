#!/usr/bin/env perl6

use RPi::Device::PiGlow;

my $pg = RPi::Device::PiGlow.new();

my @rings = (0 .. 5);

$pg.enable-output();
$pg.enable-all-leds();

signal(SIGINT).tap({ say "Reset"; $pg.reset(); exit; });


loop {
    say "Writing ring " ~ @rings[0];
    $pg.set-ring(@rings[0], 0xFE);
    for 1 .. 5 -> $clear-rings {
        say "clearing ring " ~ @rings[$clear-rings];
        $pg.set-ring(@rings[$clear-rings], 0x00);
    }
    say "updating";
    $pg.update();
    @rings = @rings.rotate;
    sleep 1;
}

# vim: expandtab shiftwidth=4 ft=perl6
