# Chronic

Scheduling thingy for Perl6

## Synopsis

```

# Static configuration;

use Chronic;

react {
    # Every minute
    whenever Chronic.every() -> $v {
        say "One: $v";
    }
    # Every five minutes
    whenever Chronic.every(minute => '*/5') -> $v {
        say "Five: $v";
    }
    # At 21:31 every day
    whenever Chronic.every(minute => 31, hour => 21) -> $v {
        say "21:31 $v";
    }

}

# Dynamic configuration

use Chronic;

my @events = (
    {
        schedule => {},
        code     => sub ($v) { say "One: $v" },
    },
    {
        schedule => { minute => '*/2' },
        code     => sub ($v) { say "Two: $v" },
    },
    {
        schedule => { minute => '*/5' },
        code     => sub ($v) { say "Five: $v" },
    },
    {
        schedule => { minute => 31, hour => 21 },
        code     => sub ($v) {  say "21:31 $v"; },
    },
);

for @events -> $event {
    Chronic.every(|$event<schedule>).tap($event<code>);
}

# This has the effect of waiting forever
Chronic.supply.wait;

```

## Description

This module provides a low-level scheduling mechanism, that be used to
create cron-like schedules, the specifications can be provided as cron
expression strings, lists of integer values or L<Junctions> of values.

There is a single class method ```every``` that takes a schedule specification
and returns a ```Supply``` that will emit a value (a ```DateTime```) on the
schedule specified.

This can be used to build custom scheduling services like ```cron``` with
additional code to read the specification from a file and arrange the
execution of the required thing or it could be used in a larger program
that may require to execute some code asynchronously periodically.

There is a single base Supply that emits an event at a 1 second frequency
in order to preserve the accuracy of the timings (in testing it may drift
by up to 59 seconds on a long run due to system latency if it didn't 
match the seconds too,) so this may be a problem on a heavily loaded
single core computer. The sub-minute granularity isn't provided for in
the interface as it is easily achieved anyway with a basic supply, it
isn't supported by a standard ```cron``` and I think most code that would
want to be executed with that frequency would be more highly optimised then
this may allow.


## Installation

Assuming you have a working perl6 installation you should be able to
install this with *ufo* :

    ufo
    make test
    make install

*ufo* can be installed with *panda* for rakudo:

    panda install ufo

Or you can install directly with "panda":

    # From the source directory
   
    panda install .

    # Remote installation

    panda install Chronic

Other install mechanisms may be become available in the future.

## Support

This should be considered experimental software until such time that
Perl 6 reaches an official release.  However suggestions/patches are
welcomed via github at

   https://github.com/jonathanstowe/Chronic

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015



