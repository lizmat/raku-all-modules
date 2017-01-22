# RPi::Device::SMBus

i²c on Raspberry Pi fo Perl6

## Synopsis

```perl6

    use RPi::Device::SMBus;

    # Obviously you will need to actually read the data sheet of your device.
    my RPi::Device::SMBus $smbus = RPi::Device::SMBus.new(device => '/dev/i2c-1', address => 0x54);

    $smbus.write-byte(0x10);

    ....

```

## Description

This is an SMBus/i²c interface that has been written and tested for
the Raspberry Pi, however it uses a fairly generic POSIX interface so if
your platform exposes the i²c interface as a character special device
it may work.

In order to use this you will need to install and configure the i2c-dev
kernel module and tools.  On a default Debian image you should be able
to just do:

    sudo apt-get install libi2c-dev i2c-tools

And then edit the ```/etc/modules``` to add the modules by adding:

    i2c-dev 
    i2c-bcm2708

And then rebooting.

Typicaly the i2c device will be ```/dev/i2c-1``` on a Raspberry Pi rev
B. or v2 or ```/dev/i2c-0``` on older versions.

You can determine the bus address of your device by doing:

    sudo i2cdetect -y 1  # replace the 1 with a 0 for older versions

(Obviously the device should be connected, consult the manual for your
device about this.)

Which should give you the hexadecimal address of your device.  Some
devices may not respond, so you may want to either check the data sheet
of your device or read the ```i2cdetect``` manual page to get other options.

It should be noted that because there is no easy way of testing this without
using physical devices then it may not work perfectly in all cases, but I'd
be delighted to receive patches for any issues found.

## Installation

Assuming you have a working Rakudo Perl 6 installation you should be able to
install this with *panda* :

    # From the source directory
   
    panda install .

    # Remote installation

    panda install RPi::Device::SMBus

This should work equally well with *zef* but I haven't tested it.

## Support

Suggestions/patches are welcomed via github at:

https://github.com/jonathanstowe/RPi-Device-SMBus

I won't be surprised if there are problems with some devices as I am
only able to test against a limited number which do not use all the
API.

## Licence

This is free software.

Please see the [LICENCE](LICENCE) file in the distribution

© Jonathan Stowe 2015, 2016, 2017
