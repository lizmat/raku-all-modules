NAME
====

Shell::Capture - capture a command's output and exit code

SYNOPSIS
========

        use Shell::Capture;

        my Shell::Capture $c .= capture('id', '-u', '-n');
        if $c.exitcode != 0 {
            die "Could not execute id -u -n\n";
        } elsif $c.lines.elems != 1 {
            die "id -u -n returned something unexpected:\n" ~ $c.lines.join("\n") ~ "\n";
        }
        say "Got my username: " ~ $c.lines[0];

        sub fail($r, @cmd) {
            die "fail with exit code $r.exitcode() and $r.lines().elems() " ~
                "line(s) of output and cmd " ~ @cmd;
        }

        $c .= capture-check(:accept(0, 3), 'sh', '-c', 'date');
        say "The current date is $c.lines()[0]" if $c.exitcode == 0;

        $c .= capture-check(:accept(0, 3), 'sh', '-c', 'date; exit 3');
        say "The current date is $c.lines()[0]" if $c.exitcode == 3;

        $c .= capture-check(:accept(0, 3), :&fail, 'sh', '-c', 'date; exit 1');
        say 'not reached, fail() dies';

DESCRIPTION
===========

This class provides two methods to execute an external command, capture its output and exit code, and, in `capture-check()`, raise an error on unexpected exit code values.

FIELDS
======

  * exitcode

        Int:D $.exitcode

    The exit code of the executed external command.

  * lines

        Str:D @.lines

    The output of the external command split into lines with the newline terminator removed.

METHODS
=======

  * method capture()

        method capture(*@cmd)

    Execute the specified command in the same way as `run()` would, then create a new `Shell::Capture` object with its `exitcode` and `lines` members set respectively to the exit code of the command and its output split into lines, as described above.

  * method capture-check()

        method capture-check(:$accept, :$fail, *@cmd)

    Execute the specified command and create a `Shell::Capture` object in the same way as `capture()`, then check the exit code against the `$accept` list (default: only 0). If the exit code is on the list, return the `Shell::Capture` object to the caller.

    If the exit code is not on the list and there is no `$fail` handler specified, output an error message to the standard error stream and terminate the program. If a fail handler is specified, invoke it with two arguments: the `Shell::Capture` object for further examination and the command executed; if the fail handler returns, `capture-check()` will return the `Shell::Capture` object to its caller (useful for writing tests).

AUTHOR
======

Peter Pentchev <[roam@ringlet.net](mailto:roam@ringlet.net)>

COPYRIGHT
=========

Copyright (C) 2016 Peter Pentchev

LICENSE
=======

The Shell::Capture module is distributed under the terms of the Artistic License 2.0. For more details, see the full text of the license in the file LICENSE in the source distribution.
