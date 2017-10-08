#!/usr/bin/env perl6

use RPi::Device::PiGlow;

my $pg = RPi::Device::PiGlow.new();

my @arms = ^3;

$pg.enable-output();
$pg.enable-all-leds();

signal(SIGINT).tap({ say "Reset"; $pg.reset(); exit; });

loop {
    say "Writing arm " ~ @arms[0];
    $pg.set-arm(@arms[0], 0xFF);
    say "clearing arm " ~ @arms[1];
    $pg.set-arm(@arms[1], 0x00);
    say "clearing arm " ~ @arms[2];
    $pg.set-arm(@arms[2], 0x00);
    say "updating";
    $pg.update();
    @arms = @arms.rotate;
    sleep 1;
}

# vim: expandtab shiftwidth=4 ft=perl6
