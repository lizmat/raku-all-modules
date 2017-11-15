[![Build Status](https://travis-ci.org/Scimon/Timer-Breakable.svg?branch=master)](https://travis-ci.org/Scimon/Timer-Breakable)

NAME
====

Timer::Breakable - Timed block calls that can be broken externally.

SYNOPSIS
========

    use Timer::Breakable;

    my $timer = Timer::Breakable.start( 10, { say "Times up" } );
    ... Stuff occurs ...
    $timer.break if $variable-from-stuff;

    say $timer.result if $timer.status ~~ Kept;

DESCRIPTION
===========

Timer::Breakable is wrapper aroud the standard Promise.in() functionality that lets you stop the timer without running it's block.

PUBLIC ATTRIBUTES
-----------------

### promise

A vowed promise that can be handed to await, anyof or allof. Note that the promises status and results can be accessed from the Timer::Breakable object directly.

PUBLIC METHODS
--------------

### start( $time where * > 0, &block )

Factory method to start the timer. Expects the time to run and the block to run on completion.

### stop()

Stops the timer. Note that the timer itself will still run to completion but the given block will not be run.

### status()

As per Promise.status()

### result()

As per Promise.result()

NOTES
=====

Version 0.1.0 updated the object creation to use start as a factory method.

AUTHOR
======

Simon Proctor <simon.proctor@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2017 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
