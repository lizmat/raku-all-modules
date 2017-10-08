use v6;

unit module RPi::Wiring::Shift;

use strict;
use warnings;
use NativeCall;
use Carp qw(carp croak verbose);

constant LIB = 'libwiringPi.so';

# Shift Library ----------------------------------------------------------------

#`[ WiringPi includes a simple shift library. This allows you to shift 8-bit data
    values out of the Pi, or into the Pi from devices such as shift-registers (e.g.
    74×595) and so-on, although it can also be used in some bit-banging scenarios.

    To use, you need to make sure your program includes the following files:
        #include <wiringPi.h>
        #include <wiringShift.h>

    Then the following two functions are avalable: ]

#`[ This shifts an 8-bit data value in with the data appearing on the dPin and
    the clock being sent out on the cPin. Order is either LSBFIRST or MSBFIRST. The
    data is sampled after the cPin goes high. (So cPin high, sample data, cPin low,
    repeat for 8 bits) The 8-bit value is returned by the function. ]
    uint8_t shiftIn (uint8_t dPin, uint8_t cPin, uint8_t order) ;

#`[ The shifts an 8-bit data value val out with the data being sent out on dPin and
    the clock being sent out on the cPin. order is as above. Data is clocked out on
    the rising or falling edge – ie. dPin is set, then cPin is taken high then low –
    repeated for the 8 bits.  ]
    void shiftOut (uint8_t dPin, uint8_t cPin, uint8_t order, uint8_t val) ;

