#!/usr/bin/env perl6

use RPi::Device::PiGlow;

my $pg = RPi::Device::PiGlow.new();

my @values = 0x01,0x02,0x04,0x08,0x10,0x18,0x20,0x30,0x40,0x50,0x60,0x70,0x80,0x90,0xA0,0xC0,0xE0,0xFF;

$pg.enable-output();
$pg.enable-all-leds();

signal(SIGINT).tap({ say "Reset"; $pg.reset(); exit; });

loop {
    say "Writing";
    $pg.write-all-leds(@values, :fix );
    @values = @values.rotate;
    sleep 1;
}

# vim: expandtab shiftwidth=4 ft=perl6
