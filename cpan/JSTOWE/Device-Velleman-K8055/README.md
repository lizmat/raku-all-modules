# Device::Velleman::K8055

A perl interface to the [Velleman USB Experiment Kit](http://www.velleman.eu/products/view/?lang=en&id=351346).

## Synopsis

```perl6
use Device::Velleman::K8055;

my $device = Device::Velleman::K8055.new(address => 0);

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
```

See also the [examples](examples) directory in the distribution.

## Description

The Velleman K8055 is an inexpensive PIC based board that allows
you to control 8 digital and 2 analogue outputs and read five digital
and 2 analog inputs via USB.  There are LEDs on the outputs that
show the state of the outputs (which is largely how I've tested this.)

I guess it would be useful for experimenting or prototyping but it's
rather big (about three times as large as a Raspberry Pi) so you
may be rather constrained if you want to use it in a project.

This module has a fairly simple interface - I guess that a higher
level abstraction could be provided but I only made it as an
experiment and am not quite sure what interface would be best
yet.

I've used the [k8055 library by Jakob Odersky](https://github.com/jodersky/k8055)
to do the low-level parts rather than binding libusb directly, but
all the information is there is someone else wants to do that.

## Install

You will need the development package of ```libusb``` in order to
build this, this should be available through your system's
package manager as ```libusb-devel``` or ```libusb-dev``` (if
you are running a Linux.) At minimum it will require the 'usb.h'
and the required library to link to in places where the C compiler
can find them.

On a system that uses ```udev``` (most probably Linux,) you will
need to make some configuration changes in order to be able to
use it as a non-privileged user. You will need to perform these
changes with root privileges.

Firstly copy the [k8055.rules](config/k8055.rules) file to the
udev rules directory (```/etc/udev/rules.d``` on a typical
installation,)

    cp config/k8055.rules /etc/udev/rules.d

Then create a new group called ```k8055```:

    groupadd -r k8055

Finally add yourself (or other users that require access to the
device,) to the new group:

    usermod -a -G k8055 $(USER)

Where $(USER) is the user name of the user that want access.
The access changes won't be available until the device is
next plugged in and the user logs in again.

If the above steps haven't been done before trying to install
the module, it will attempt to skip most of the tests and
may even succeed in installing but may not work well.

If you have a working rakudo Perl 6 installation you should 
be able to install with ```zef``` :

    zef install Device::Velleman::K8055

Other installers may be available in the future.

## Support

This is largely experimental and might prove fiddly to install
so I won't be entirely surprised if you have problems with it,
if however you have any suggestions, feedback or improvements
than please post them on [Github](https://github.com/jonathanstowe/Device-Velleman-K8055-Native/issues)
or even better send a pull request.

## Copyright & Licence

This is free software, see the [LICENCE](LICENCE) file in the
distrubution.

© Jonathan Stowe 2016 - 2019

The terms of the k8055 library used are described in its
[README](https://github.com/jodersky/k8055/blob/master/README.md).
