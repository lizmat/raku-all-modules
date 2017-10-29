NAME
====

RPi::ButtonWatcher - A button push event supplier

SYNOPSIS
========

    use RPi::Wiring::Pi;
    use RPi::ButtonWatcher;

    die if wiringPiSetup() != 0;

    # Takes WiringPi pin numbers.
    my $watcher = RPi::ButtonWatcher.new(pins => ( 4, 5, 6 ), edge => BOTH, PUD => PULL_UP);
    $watcher.getSupply.tap( -> %v {
        my $e = %v<edge> == Edge.RISING ?? 'up' !! 'down';
        say "Pin: %v<pin>, Edge: $e";
    });

DESCRIPTION
===========

This library provides a supplier of GPIO pin state changes.

Read/write access to */sys/class/gpio/export* and */sys/class/gpio/gpioXX/* is required for this library to work. This usually means the user running the code has to be in the *gpio* group.

This module uses polling to detect state changes. A polling interval of 0.1 seconds is usually fast enough for normal button pushes.

The Sysfs interface is documented here: [https://www.kernel.org/doc/Documentation/gpio/sysfs.txt](https://www.kernel.org/doc/Documentation/gpio/sysfs.txt)

METHODS
=======

new
---

Do initialize WiringPi before using this class using `wiringPiSetup`!

Takes the following parameters:

  * pins

A list of WiringPi pin numbers to watch.

  * edge

The edges to listen for.

    * `Edge.RISING`

Triggered when a button is released.

    * `Edge.FALLING`

Triggered when a button is pressed.

    * `Edge.BOTH`

Triggered on both, button presses and releases.

  * debounce

Time in seconds to sleep between polls. Faster means more responsive, but also more system resource eating. Defaults to 0.1 (100ms).

getSupply
---------

Returns a supply that can be tapped. The supply will emit hashes with two entries:

  * pin

The WiringPi pin number that was triggered.

  * edge

Either `Edge.RISING` or `Edge.FALLING`.
