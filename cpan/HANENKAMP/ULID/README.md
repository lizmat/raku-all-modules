NAME
====

ULID - Universally Unique Lexicographically Sortable Identifier

SYNOPSIS
========

    use ULID;

    say ulid; #> 01D3HRFBR2WBZHW2HZ6CYSJ9JB

DESCRIPTION
===========

This implements the [ULID specification](https://github.com/ulid/spec) in Perl. Using the `ulid` function will generate a random unique ID according to that specification. These unique IDs can be generated in sortable order and are encoded in a Base 32 encoding.

EXPORTED SUBROUTINES
====================

sub ulid
--------

    our sub ulid(
        Int:D() $now       = ulid-now,
        Bool:D :$monotonic = False,
        :&random-function  = &random-number,
        --> Str:D
    ) is export(:DEFAULT, :ulid)

With no arguments, this returns a string containing the ULID for the current moment.

The `$now` argument may be set to ULID's notion of time, which is number of milliseconds since the POSIX epoch start. Because this is annoying to calculate in Perl, this module provides the [ulid-now](#sub ulid-now) to do the conversion from [Instant](Instant) for you.

The `$monotonic` argument turns on monotonic ULID generation, which ensures that ULIDs generated sequentially during the same millisecond will also be issued in sorted order. The first time this is done for a given millisecond, the ULID is generated randomly as usual. The second time, however, the next ULID will be identical to the previous ULID, but increased in value by 1. This process may be repreated until the final carry bit occurs, at which point an [X::ULID](#X::ULID) exception will be thrown.

**CAVEAT:** As of this writing, this is implemented in Perl and has not been much optimized, so it is unlikely in the extreme that you will be able to generate 2 ULIDs during the same millisecond unless you are passing the `$now` argument to deliberately generate multiple per second.

The `&random-function` argument allows you to provide an alternative to the built-in random function used, which just depends on Perl's `rand`. The function should be defined similar to the default implementation which looks something like this:

    sub (Int:D $max --> Int:D) { $max.rand.floor }

That is, given an integer, it should return an integer `$n` such that `0 <= $n < $max `.

sub ulid-now
------------

    our sub ulid-now(Instant:D $now = now --> Int:D) is export(:time)

This method can be used to retrieve the number of milliseconds since the POSIX epoch. Or you may choose to pass an [Instant](Instant) to convert to such a value.

sub ulid-time
-------------

    our sub ulid-time(Int:D $now --> Seq:D) is export(:parts)

This method will allow you to return just the time part of a ULID. The value will convert a number of milliseconds since the POSIX epoch, `$now`, into the first 10 characters of the ULID. These are returned a sequence, so you'll have to join them yourself if you want a string.

sub ulid-random
---------------

    our sub ulid-random(
        Int:D $now,
        :&random-function = &random-number,
        Bool:D :$monotonic = False,
        --> Seq:D
    ) is export(:parts)

This method will allow you to return just the random part of a ULID. The value returned will be 16 characters long in a sequence.

This must be passed the `$now` to use to generate the sequence, which will be stord in case `$monotonic` is passed during a subsequent call.

See `&random-function` and `$monotonic` as described for [ulid](#sub ulid) for details on how they work.

DIAGNOSTICS
===========

X::ULID
-------

This exception will be thrown if a ULID cannot be generated for some reason by [ulid](#sub ulid). Currently, the only case where this will be true is when monotonic ULIDs are generated for a given millisecond and the module runs out of ULIDs that can be generated monotonically.

In that case, the message will be "monotonic ULID overflow". Enjoy.

