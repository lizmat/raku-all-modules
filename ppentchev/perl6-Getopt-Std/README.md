NAME
====

Getopt::Std - Process single-character options with option clustering

SYNOPSIS
========

        use Getopt::Std;

        # Classical usage, slightly extended:
        # - for options that take an argument, return only the last one
        # - for options that don't, return a string containing the option
        #   name as many times as the option was specified

        my Str:D %opts = getopts('ho:V', @*ARGS);
        CATCH { when X::Getopt::Std { .message.note; usage } };

        version() if %opts<V>;
        usage(True) if %opts<h>;
        exit(0) if %opts{<V h>}:k;

        my $outfile = %opts<o> // 'a.out';

        # "All options" usage:
        # - for options that take an argument, return an array of all
        #   the arguments supplied if specified more than once
        # - for options that don't, return the option name as many times
        #   as it was specified

        my %opts = getopts-all('o:v', @*ARGS);

        $verbose_level = %opts<v>.elems;

        for %opts<o> -> $fname {
            process_outfile $fname;
        }

        # Permute usage (with both getopts() and getopts-all()):
        # - don't stop at the first non-option argument, look for more
        #   arguments starting with a dash
        # - stop at an -- argument

        my Str:D %opts;
        %opts = getopts('ho:V', @*ARGS, :permute);

DESCRIPTION
===========

This module exports the `getopts()` and `getopts-all()`> functions for parsing command-line arguments similarly to the POSIX getopt(3) standard C library routine.

The options are single letters (no long options) preceded by a single dash character. Options that do not accept arguments may be clustered (e.g. `-hV` for `-h` and `-V`); the last one may be an option that accepts an argument (e.g. `-vo outfile.txt`). Options that accept arguments may have their argument "glued" to the option or in the next element of the arguments array, i.e. `-ooutfile` is equivalent to `-o outfile`. There is no equals character between an option and its argument; if one is supplied, it will be considered the first character of the argument.

If an unrecognized option character is supplied in the arguments array, `getopts()` will throw an exception. Otherwise it will return a hash with the options found in the arguments array. The key in the returned hash is the option name (e.g. `h` or `o`); the value is the option argument for options that accept one or the option name (as many times as it has been specified) for options that do not.

FUNCTIONS
=========

  * sub getopts

        sub getopts(Str:D $optstr, @args, Bool :$nonopts,
            Bool :$permute, Bool :$unknown) returns Hash[Str:D]

    Look for the command-line options specified in `$optstr` in the `@args` array. Return the options found in a hash, leave only the non-option arguments in the `@args` array.

    Note that if an option is specified more than once on the command line, `getopts()` will only record the last argument in the returned hash; see also the `getopts-all()` function below.

    The `:permute` flag specifies whether option parsing should stop at the first non-option argument, or go on and process any other arguments starting with a dash. A double dash (<var>--</var>) stops the processing in this case, too.

    The `:unknown` flag controls the handling of unknown options - ones not specified in the `$optstr`, but present in the `@args`. If it is false (the default), `getopts()` will throw an exception; otherwise, the unknown option character will be present in the returned hash as an argument to a `:` option and `getopts()` will still succeed. This is similar to the behavior of some `getopt(3)` implementations if `$optstr` starts with a `:` character.

    The `:nonopts` flag makes `getopts()` treat each non-option argument as an argument to an option with a character code 1. This is similar to the behavior of some `getopt(3)` implementations if `$optstr` starts with a `-` character. The `:permute` flag is redundant if `:nonopts` is specified since the processing will not stop until the arguments array has been exhausted.

    Throws an `X::Getopt::Std` exception if an invalid option string has been specified or an unknown option has been found in the arguments array.

    Current API available since version 1.0.0.

  * sub getopts-all

        sub getopts-all(Str:D $optstr, @args, Bool :$nonopts,
            Bool :$permute, Bool :$unknown) returns Hash[Array[Str:D]]

    Same as the `getopts()` function, but all the returned values are arrays containing all the specified arguments if any options have been specified more than once.

    For example, the command line <var>-vI foo -I bar -v</var>, matched against an option string of <var>I:v</var>, would produce `{ :I<bar> :v<vv> }` with `getopts()` and `{ :I(['foo', 'bar']) :v(['v', 'v']) }` with `getopts-all()`.

    Current API available since version 1.0.0.

AUTHOR
======

Peter Pentchev <[roam@ringlet.net](mailto:roam@ringlet.net)>

COPYRIGHT
=========

Copyright (C) 2016, 2017 Peter Pentchev

LICENSE
=======

The Getopt::Std module is distributed under the terms of the Artistic License 2.0. For more details, see the full text of the license in the file LICENSE in the source distribution.
