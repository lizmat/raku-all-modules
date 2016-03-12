use v6;
class RPi::Device::PiFace {
  use NativeCall;

  # Setup Functions
  our sub setup-piface(int32) returns int32 is native('wiringPiDev')
                                            is symbol('piFaceSetup') { * };


=begin pod

=head1 NAME

RPi::Device::PiFace - Perl6 module to drive the PiFace 2 GPIO expansion board for
the Raspberry Pi 2.

=head1 SYNOPSIS

  use RPi::Device::PiFace;

=head1 DESCRIPTION

RPi::Device::PiFace controls the PiFace 2 expansion board for the Raspberry Pi 2
which adds 2 banks of 8 GPIO ports (a total of 16 extra I/O pins/ports).
The RPi 2 uses its SPI interface pins to control the PiFace 2.

This module uses Perl6's NativeCall module to interface the WiringPi C library
and the MCP23S17.c SPI driver from wiringpi.org.

=head1 USAGE

use RPi;
use RPi::Device::PiFace;

RPi::Wiring::setup();

# Setup the PiFace board
# In effect, overlays RPi methods with equivalent methods from WiringPi's PiFace
# C library
my $res = RPi::Device::PiFace::setup-piface(200);

loop {
  blink(202,500);
}

sub blink($pin,$delay) {
  RPi::Wiring::digital-write($pin, 1);# On
  RPi::Wiring::delay($delay);# mS
  RPi::Wiring::digital-write($pin, 0);# Off
  RPi::Wiring::delay($delay);
}

=head1 AUTHOR

Gary Ashton-Jones <gary@ashton-jones.com.au>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Gary Ashton-Jones

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod

}
