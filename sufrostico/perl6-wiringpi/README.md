# Perl6 - WiringPI [![Build Status](https://travis-ci.org/Sufrostico/perl6-wiringpi.svg?branch=master)](https://travis-ci.org/Sufrostico/perl6-wiringpi)

Perl6 Wrapper for the WiringPi C library (to use with the raspberry pi).

From the [WiringPI site](http://wiringpi.com):
  > WiringPi is a GPIO access library written in C for the BCM2835 used in the
  > Raspberry Pi. It’s released under the GNU LGPLv3 license and is usable from C
  > and C++ and many other languages with suitable wrappers. It’s designed to be
  > familiar to people who have used the Arduino “wiring” system.

## Installation

 1. This module requires the wiringpi library to installed manually following
    [this guide](http://wiringpi.com/download-and-install/)

 1. Installation using zef

    - From sources:
        ```
            zef install .
        ```

## Current status

 - Tested with WiringPi version 2.39.
 - Only the main functions of the library have been mapped using NativeCall.
 - SPI works.
 - I2C, Serial, Shift and SoftTone are there but untested.

## Testing

To run tests:

```
    prove -e perl6
```

## Author

Aurelio Sanabria, sufrostico on #perl6 and github (https://github.com/sufrostico/)

## License

GPL - General Public License

