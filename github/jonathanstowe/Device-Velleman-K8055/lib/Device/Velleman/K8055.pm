use v6.c;

=begin pod

=head1 NAME

Device::Velleman::K8055 - interface with Velleman USB Experiment Board.

=head1 SYNOPSIS

=begin code

use Device::Velleman::K8055;

my $device = Device::Velleman::K8055.new(address => 0);

# Blink alternate LEDs
react {
    whenever Supply.interval(0.5) -> $i {
        if $i %% 2 {
            $device.set-all-digital(0b10101010);
        }
        else {
            $device.set-all-digital(0b01010101);
        }
    }
    whenever signal(SIGINT) {
        $device.close(:reset);
        exit;
    }
}

=end code

=head1 DESCRIPTION

The Velleman K8055 is an inexpensive PIC based board that allows you
to control 8 digital and 2 analogue outputs and read five digital and
2 analog inputs via USB.  There are LEDs on the outputs that show the
state of the outputs (which is largely how I've tested this.)

I guess it would be useful for experimenting or prototyping but it's
rather big (about three times as large as a Raspberry Pi) so you may be
rather constrained if you want to use it in a project.

This module has a fairly simple interface - I guess that a higher level
abstraction could be provided but I only made it as an experiment and
am not quite sure what interface would be best yet.

I've used the L<k8055 library by Jakob
Odersky|https://github.com/jodersky/k8055> to do the low-level parts
rather than binding libusb directly, but all the information is there
is someone else wants to do that.


=head1 METHODS

=head2 method new

    method new(Int :$!address where 0 <= * < 4 = 0, Bool :$debug)

The constructor of the class.  This will attempt to open the 
device, throwing an exception if it is unable.  The C<address>
parameter can be used if there is more than one board plugged
in (the default is 0, the first board present.) The C<:debug>
parameter will cause the underlying library to output diagnostic
information to STDERR, so you probably want to use it sparingly.

=head2 method close

    method close(Bool :$reset = False)

This closes the device, freeing up any resources.  If the
C<:reset> parameter is provided, the outputs will be set
to 0 switching off the built in LEDs.

=head2 method set-all-digital

	method set-all-digital(Int $bitmask where * < 256) returns Bool

This sets all the digital outputs based on the bitmask (in the range
0 - 255,) where each of the eight bits represents a single digital
output, with the least significant bit being output 1 (nearest the
edge of the board,) and so forth.

=head2 method set-digital

        method set-digital(Int $channel where * < 8, Bool $v) returns Bool

This sets an individual digital channel, numbered 0 - 7 where 0 is
output 1, setting True turns the output on and False off.

=head2 method set-all-analog

        method set-all-analog(AnalogValue $analog0, AnalogValue $analog1) returns Bool

This sets the analog outputs to a voltage in the range 0-5 volts based on the supplied
values in the range 0-255, I'm not sure how accurate it is.

=head2 method set-analog

        method set-analog(Int $channel where 2 > * => 0, AnalogValue $value) returns Bool

This sets the specified analog channel (0 or 1) to the specified value as described above.

=head2 method reset-counter

        method reset-counter(Int $counter where 2 > * => 0) returns Bool

The board provides two counters on the first two digital inputs.  This resets the specifed
counter to 0.

=head2 method set-debounce-time

        method set-debounce-time(Int $counter where 2 > * => 0, Int $debounce where * < 7450) returns Bool {

This sets the timer for the built in "debounce" of the counters on digital inputs 1 or 2, the debounce time
is a value 0..7450 (in milliseconds.)

=head2 method get-all-input

        method get-all-input(Bool :$quick = False)

This returns a list of the five input values which are:

=item digitalbitmask - a five bit integer indicating the state of the five digital inputs.

=item analog0 - first analog input

=item analog1 - second analog input

=item counter0 - first counter

=item counter1 - second counter


If the C<quick> parameter is supplied, the values may be those buffered and not
reflect the actual state of the inputs.


=head2 method get-all-output

        method get-all-output()

The board itself doesn't provide a mechanism to get the output values, and this is
emulated from the internal cache used by the library.  A list of five values is
returned:

=item digitalBitmask - bitmask value of digital outputs (there are 8 digital outputs)

=item analog0 - value of first analog output

=item analog1 - value of second analog output

=item debounce0 - value of first counter's debounce time [ms]

=item debounce1 - value of second counter's debounce time [ms]

=end pod

use NativeCall;

class Device::Velleman::K8055 {

    constant LIB = %?RESOURCES<libraries/k8055>.Str;

    has Int $.address;
    
    enum Error (
                   SUCCESS => 0,
                   ERROR => -1,
                   INIT_LIBUSB => -2,
                   NO_DEVICES => -3,
                   NO_K8055 => -4,
                   ACCESS => -6,
                   OPEN => -7,
                   CLOSED => -8,
                   WRITE => -9,
                   READ => -10,
                   INDEX => -11,
                   MEM => -12
                );
    
    my class Device is repr('CPointer') {

    
        sub k8055_close_device(Device $device) is native(LIB)  { * }

        method close() {
            k8055_close_device(self);
        }
     
        sub k8055_set_all_digital(Device $device, int32 $bitmask) is native(LIB) returns int32 { * }

        method set-all-digital(Int $bitmask where * < 256) returns Bool {
            my $rc = k8055_set_all_digital(self, $bitmask);
            $rc == SUCCESS;
        }
    
        sub k8055_set_digital(Device $device, int32 $channel, bool  $value) is native(LIB) returns int32 { * }

        method set-digital(Int $channel where * < 8, Bool $v) returns Bool {
            my $rc = k8055_set_digital(self, $channel, $v.value);
            $rc == SUCCESS;
        }
    
        sub k8055_set_all_analog(Device $device, int32 $analog0, int32 $analog1) is native(LIB) returns int32 { * }

        subset AnalogValue of Int where * < 256;

        method set-all-analog(AnalogValue $analog0, AnalogValue $analog1) returns Bool {
            my $rc = k8055_set_all_analog(self, $analog0, $analog1);
            $rc == SUCCESS;
        }
    
        sub k8055_set_analog(Device $device, int32 $channel, int32 $value) is native(LIB) returns int32 { * }

        method set-analog(Int $channel where 2 > * >= 0, AnalogValue $value) returns Bool {
            my $rc = k8055_set_analog(self, $channel, $value);
            $rc == SUCCESS;
        }
    
        sub k8055_reset_counter(Device $device, int32 $counter) is native(LIB) returns int32 { * }

        method reset-counter(Int $counter where 2 > * >= 0) returns Bool {
            my $rc = k8055_reset_counter(self, $counter);
            $rc == SUCCESS;
        }
    
        sub k8055_set_debounce_time(Device $device, int32 $counter, int32 $debounce) is native(LIB) returns int32 { * }

        method set-debounce-time(Int $counter where 2 > * >= 0, Int $debounce where * < 7450) returns Bool {
            my $rc = k8055_set_debounce_time(self, $counter, $debounce);
            $rc == SUCCESS;
        }
    
        sub k8055_get_all_input(Device $device,     int32 $digitalBitmask is rw, 
                                                    int32 $analog0 is rw, 
                                                    int32 $analog1 is rw, 
                                                    int32 $counter0  is rw, 
                                                    int32 $counter1 is rw, bool $quick) is native(LIB) returns int32 { * }

        method get-all-input(Bool :$quick = False) {
            my int32 $digitalBitmask;
            my int32 $analog0;
            my int32 $analog1;
            my int32 $counter0;
            my int32 $counter1;
            my $rc = k8055_get_all_input(self, $digitalBitmask, $analog0, $analog1, $counter0, $counter1, $quick.value);

            if $rc != SUCCESS {
                die "Failed to get inputs ({ Error($rc) })";
            }
            $digitalBitmask, $analog0, $analog1, $counter0, $counter1;
        }
    
        sub k8055_get_all_output(Device $device,    int32 $digitalBitmask is rw,
                                                    int32 $analog0 is rw,
                                                    int32 $analog1 is rw,
                                                    int32 $debounce0 is rw,
                                                    int32 $debounce1 is rw) is native(LIB)  { * }
        method get-all-output() {
            my int32 $digitalBitmask;
            my int32 $analog0;
            my int32 $analog1;
            my int32 $debounce0;
            my int32 $debounce1;
            k8055_get_all_output(self, $digitalBitmask, $analog0, $analog1, $debounce0, $debounce1);

            $digitalBitmask, $analog0, $analog1, $debounce0, $debounce1;
        }

        method reset() {
            self.set-all-digital(0) && self.set-all-analog(0,0);
        }
    }
    
    sub k8055_open_device(int32 $port, Pointer $device is rw) is native(LIB) returns int32 { * }

    method !open-device(Int :$port where { 0 <= $_ < 4 } = 0) returns Device {
        my $p = Pointer[Device].new;
        my $rc = k8055_open_device($port, $p);
            
        if $rc != SUCCESS {
                die "Cannot open device";
        }
        $p.deref;
    }

    method close(Bool :$reset = False) {
        if $reset {
            self.reset;
        }
        $!device.close;
    }
    
    sub k8055_debug(bool $value) is native(LIB)  { * }

    has Device $!device handles <set-all-digital set-digital set-all-analog set-analog reset-counter set-debounce-time get-all-input get-all-output reset>;

    submethod BUILD(Int :$!address where 0 <= * < 4 = 0, Bool :$debug) {
        $!device = self!open-device(:$!address);
        if $debug {
            k8055_debug(1);
        }
    }
    
}

# vim: expandtab shiftwidth=4 ft=perl6
