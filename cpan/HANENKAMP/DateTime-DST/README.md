NAME
====

DateTime::DST - make localtime[8] available as is-dst()

SYNOPSIS
========

    use DateTime::DST;

    my $non-dst = DateTime.new(:2016year, :1month, :15day, :0hour, :0minute, :0second);
    my $dst     = DateTime.new(:2016year, :6month, :15day, :0hour, :0minute, :0second);

    say is-dst($non-dst);         # False
    say is-dst($non-dst.Instant); # False
    say is-dst($non-dst.posix);   # False

    say is-dst($dst);             # True
    say is-dst($dst.Instant);     # True
    say is-dst($dst.posix);       # True

DESCRIPTION
===========

This is nothing too fancy, just exports a function named `is-dst` which can be used to test for Daylight Savings Time from a DateTime object, an Int (expecting seconds since the start of the POSIX time_t epoch), or an Instant.

FUNCTIONS
=========

is-dst
------

    multi is-dst(Instant $time) returns Bool
    multi is-dst(DateTime $time) returns Bool
    multi is-dst(Int $time) returns Bool

Returns `True` if the C-standard library `localtime` function returns a true value for the DST flag or `False` otherwise. This is basically the same as `localtime($time)[8]` in Perl 5.

AUTHOR
======

Sterling Hanenkamp `<hanenkamp@cpan.org> `

COPYRIGHT AND LICENSE
=====================

Copyright 2016 Andrew Sterling Hanenkamp.

This software is made available under the same terms as Perl 6 itself.
