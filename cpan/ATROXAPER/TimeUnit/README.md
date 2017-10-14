[![Build Status](https://travis-ci.org/atroxaper/p6-TimeUnit.svg?branch=master)](https://travis-ci.org/atroxaper/p6-TimeUnit)

TimeUnit
========

Library for conversion a time unit to another.

Purpose
-------

* Add possibility to use different time units in
code - not only seconds:

        sub beep-after($time, TimeUnit:D $unit) { ... }
        beep-after(5, hours);
        beep-after(3, seconds);

* Add a simple way for conversion time units from
one to another without any 'magic numbers' in code:

        say 'In 36 hours contains ', seconds.from(:36hours), ' seconds.';

Exported constants
------------------

**nanos** - just nanoseconds;

**micros** - is a thousand of nanoseconds;

**millis** - is a thousand of microseconds;

**seconds** - is a thousand of milliseconds;

**minutes** - is sixty seconds;

**hours** - is sixty minutes;

**days** - is twenty four hours;

Available methods
-----------------

With any constants you can use methods **from**, **to-nanos**, **to-micros**, **to-millis**,
**to-seconds**, **to-minutes**, **to-hours**, **to-days** for conversion numbers 
from one unit to another like this:

        nanos.to-hours(432);      # convert 432 nanosecons to 0.00000000012 hour
        hours.from(90, minutes);  # retrieve 1.5 hours from 90 minutes
        seconds.from(:17minutes); # retrieve 1020 seconds 17 minutes in short named form
        minutes.from(hours => 3.6);
            # retrieve 216 minutes from 3.6 (3:36) hours in full named form

Sources
-------

[GitHub](https://github.com/atroxaper/p6-TimeUnit)

Author
------

Mikhail Khorkov <atroxaper@cpan.org>

License
-------

See [LICENSE](LICENSE) file for the details of the license of the code in this repository.

       



