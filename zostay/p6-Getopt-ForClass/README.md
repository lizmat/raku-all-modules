NAME
====

Getopt::ForClass - Use MAIN to dispatch to a class

SYNOPSIS
========

    #!/usr/bin/env perl6
    use Getopt::ForClass;

    class MyApp {
        has $.token;

        method BUILD(:$!token) { }

        method list-things(:$filter) { ... }
        method add-thing($name) { ... }
        method remove-thing($name, Bool :$cascade) { ... }
    }

    our &MAIN := build-main-for-class(
        class => MyApp,
    );

    # On the command-line:
    # % myapp --token=abc123 list-things --filter red
    # % myapp --token=abc123 add-thing socks
    # % myapp --token=abc123 remove-thing shrubbery --cascade

DESCRIPTION
===========

This module exports a function, `build-main-for-class`, which takes a class type and uses it to setup a `MAIN` function that is able to execut the various methods of that class as sub-commands of the script.

METHODS
=======

sub build-main-for-class
------------------------

    sub build-main-for-class(:$class!, :$methods = *) returns Routine:D

This routine is exported by default. Given a `$class`, it will inspect that class and generate a `MAIN` function that is able to execute one of the methods of that class per run. It does this by generating a multisub, which may be assigned to `MAIN` in your program.

Specifically, it does the following:

  * 1. One `MAIN` multisub candidate is generated for each method in the class (limited by the smartmatch in `$methods`, see below).

  * 2. Each `MAIN` candidate will provide command-line options based upon the `BUILD` submethod for the class. If no `BUILD` is provided, then no attributes will be set during construction.

  * 3. The first positional argument accepted by each `MAIN` candidate is the name of one of the methods in the class.

  * 4. The remaining positional and named arguments for each `MAIN` candidate are those taken from `BUILD` and those taken from the method of the class this candidate is associated with.

When run, the `MAIN` method will first construct an object by calling the `new` method and passing to that method the same parameters as are defined in `BUILD`. It will then call the method for the selected candidate passing to that method all the arguments given on the command-line.

sub MAIN_HELPER
---------------

    sub MAIN_HELPER($retval = 0)

In addition to generating the `MAIN` routine, this module also provides a `MAIN_HELPER`, which will parse the command-line arguments to call the generated `MAIN` subroutine.

This implementation will attempt to locate the most appropriate `MAIN` candidate using parameters given on the command-line. It will then organize and pass the command-line parameters to the `MAIN` candidate. This works somewhat differently from the Perl6 native `MAIN_HELPER` (at least as of this writing):

  * * Any parameter of the form `--NAME=VALUE` will be treated as a named parameter. If the candidate explicitly defines that named parameter with a numeric type, the value will be converted to a number before being passed. If it defines a boolean type, the value will be converted to False if it matches "1", "y", "yes", or "true" (using a case insensitive match) and True otherwise. Otherwise, the string will be passed as is.

  * * Any parameter of the form `--NAME` will be treated as a named parameter. If the candidate explicityly defines that named parameter as boolean, it will be set to a True value. Any other type is assumed to require a parameter so the next argument on the command-line must be a parameter. If the type of the named parameter is numeric, the value will be coerced into a number before being passed.

  * * Any parameter of the form `--no-NAME` will be treated as a named parameter. The named parameter will be set to False.

  * * Any parameter following `--` will be treated as a positional parameter, even if it takes on one of the forms named above.

  * * Any other parameter is treated as a positional parameter. Positional parameters will be converted to boolean or numbers based upon type.

This implementation is less picky about the ordering of parameters than the built-in Perl 6 implementation that is in place as of this writing.

AUTHOR
======

Sterling Hanenkamp `<hanenkamp@cpan.org> `

COPYRIGHT & LICENSE
===================

Copyright 2016 Sterling Hanenkamp.

This software is licensed under the same terms as Perl 6.
