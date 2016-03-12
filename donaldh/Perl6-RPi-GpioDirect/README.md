RPi::GpioDirect
===============

Access the Raspberry Pi GPIO

Overview
--------

The RPi::GpioDirect module provides access to the Raspberry Pi GPIO without any dependency on C libraries.
RPi::GpioDirect makes use of /dev/gpiomem so that it can run without elevated privileges.

RPi::GpioDirect has only been tested with a Raspberry Pi 3 but is likely to work with a Pi 2. RPi::GpioDirect is also
dependent on a kernel with /dev/gpiomem.

Installation
------------

    $ panda install RPi::GpioDirect

Usage
-----

```
use RPi::GpioDirect;

my $pi = RPi::GpioDirect.new;

say 'Pin  Name      Value  Mode';
for $pi.gpio-pins -> $pin {
    say sprintf('%2s   %-8s  %5s  %4s',
                $pin, $pi.pin-name($pin), $pi.read($pin), $pi.function($pin)
               );
}

say '';
say 'Pin  Name      Value';
for 11, 12 -> $pin {
    $pi.set-function($pin, Out);
    for Off, On, Off, On -> $value {
        $pi.write($pin, $value);
        say sprintf('%2s   %-8s  %5s',
                    $pin, $pi.pin-name($pin), $pi.read($pin));
    }
}
```

Author
------

Donald Hunter - donaldh @ #perl6
