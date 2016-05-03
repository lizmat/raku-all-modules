# Chronic

Scheduling thingy for Perl6

[![Build Status](https://travis-ci.org/jonathanstowe/Chronic.svg?branch=master)](https://travis-ci.org/jonathanstowe/Chronic)

## Synopsis

```perl6

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

There is a class method ```every``` that takes a schedule specification
and returns a ```Supply``` that will emit a value (a ```DateTime```) on
the schedule specified. There is also a method ```at``` (also a class
method) that returns a Promise that will be kept at a specified point
in time (as opposed to ```Promise.in``` which will return a Promise that
will be kept after a specified number of seconds.)

This can be used to build custom scheduling services like ```cron```
with additional code to read the specification from a file and arrange
the execution of the required thing or it could be used in a larger
program that may require to execute some code asynchronously periodically.

There is a single base Supply that emits an event at a 1 second frequency
in order to preserve the accuracy of the timings (in testing it may drift
by up to 59 seconds on a long run due to system latency if it didn't match
the seconds too,) so this may be a problem on a heavily loaded single core
computer. The sub-minute granularity isn't provided for in the interface
as it is easily achieved anyway with a basic supply, it isn't supported by
a standard ```cron``` and I think most code that would want to be executed
with that frequency would be more highly optimised then this may allow.

## Installation

If you have a working Rakudo Perl 6 you can install directly with "panda":

    # From the source directory
   
    panda install .

    # Remote installation

    panda install Chronic

Although I haven't tested it, I can't see any reason why "zep" or some
equally capable package manage that may come along shouldn't work.

## Support

Suggestions/patches are welcomed via github at

https://github.com/jonathanstowe/Chronic

## Licence

This is free software.

Please see the [LICENCE](LICENSE) file in the distribution.

© Jonathan Stowe 2015, 2016
