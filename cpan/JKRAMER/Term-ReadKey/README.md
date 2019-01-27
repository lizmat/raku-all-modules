NAME
====

Term::ReadKey

DESCRIPTION
===========

Read single (unbuffered) keys from terminal.

SYNOPSIS
========

    use Term::ReadKey;

    react {
      whenever key-pressed(:!echo) {
        given .fc {
          when 'q' { done }
          default { .uniname.say }
        }
      }
    }

FUNCTIONS
=========

read-key(Bool :$echo = True --> Str)
------------------------------------

Reads one unbuffered (unicode) character from STDIN and returns it as Str or Nil if nothing could be read. By default the typed character will be echoed to the terminal unless `:!echo` is passed as argument.

key-pressed(Bool :$echo = True --> Supply)
------------------------------------------

Returns a supply that emits characters as soon as they're typed (see example in SYNOPSIS). The named argument `:$echo` can be used to enable/disable echoing of the character (on by default).

AUTHOR
======

Jonas Kramer <jkramer@mark17.net>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Jonas Kramer.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

