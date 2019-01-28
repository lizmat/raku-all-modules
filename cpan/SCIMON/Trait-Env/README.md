[![Build Status](https://travis-ci.org/Scimon/p6-Trait-Env.svg?branch=master)](https://travis-ci.org/Scimon/p6-Trait-Env)

NAME
====

Trait::Env - Trait to set an attribute from an environment variable.

SYNOPSIS
========

    use Trait::Env;
    class Test {
        # Sets from %*ENV{HOME}. Undef if the var doesn't exist
        has $.home is env;

        # Sets from %*ENV{TMPDIR}. Defaults to '/tmp'
        has $.tmpdir is env is default "/tmp";

        # Sets from %*ENV{EXTRA_DIR}. Defaults to '/tmp'
        has $.extra-dir is env( :default</tmp> );

        # Set from %*ENV{WORKDIR}. Dies if not set.
        has $.workdir is env(:required);

        # Set from %*ENV{READ_DIRS.+} ordered lexically
        has @.read-dirs is env;

        # Set from %*ENV{PATH} split on ':'
        # has @.path is env(:sep<:>);
        # Or default to the $*DISTRO.path-sep value
        has @.path is env;      
        
        # Set from %*ENV{NAME_MAP} data split on ';' pairs split on ':'
        # EG a:b;c:d => { "a" => "b", "c" => "d" }
        has %.name-map is env( :sep<;>, :kvsep<:> );

        # Get all pairs where the key ends with '_POST'
        has %.post-map is env( :post_match<_POST> );

        # Get all pairs where the Key starts with 'PRE_'
        has %.pre-map is env( :pre_match<PRE_> );

        # Get all pairs where the Key starts with 'PRE_' and ends with '_POST'
        has %.both-map is env( :pre_match<PRE_>, :post_match<_POST> );
    }

    # Sets from %*ENV{HOME}. Undef if the var doesn't exist
    has $home is env;

    # Sets from %*ENV{PATH}. Uses default path seperator
    has @path is env;

DESCRIPTION
===========

Trait::Env is exports the new trait `is env`.

Currently it's only working on Class / Role Attributes but I plan to expand it to variables as well in the future. 

Note the the variable name will be uppercased and any dashes changed to underscores before matching against the environment. This functionality may be modifiable in the future.

For Booleans the standard Empty String == `False` other String == `True` works but the string "True" and "False" (any capitalization) will also map to True and False respectively.

If a required attribute is not set the code will raise a `X::Trait::Env::Required::Not::Set` Exception.

Defaults can be set using the standard `is default` trait or the `:default` key. Note that for Positional attributes only the `:default` key works.

Positional attributes will use the attribute name (after coercing) as the prefix to scan %*ENV for. Any keys starting with that prefix will be ordered by the key name lexically and their values put into the attribute.

Alternatively you can use the `:sep` key to specify a seperator, in which case the single value will be read based on the name and the list then created by spliting on this seperator.

If there is a single matching environment variable and no `:sep` key is set then the system will fall back to splitting on the `$*DISTRO.path-sep` value as a seperator.

Hashes can be single value with a `:sep` key to specify the seperator between pairs and a `:kvsep` to specifiy the seperator in each pair between key and value.

Hashes can also be defined by giving a `:post_match` or `:pre_match` arguments (or both). Any Environment variable starting with `:pre_match` is defined or ending with `:post-match` if defined will be included.

Scalars, Positionals and Associative attributes can all be typed.

Variables can also be defined with `is env` following the same rules. 

Attribute or Variable only `is env` traits can be loaded individually with `Trait::Env::Attribute` and `Trait::Env::Variable`.

Note
----

Currently there is a known issue with the Attribute code which means it can't be precompiled. The Variable code does work precompiled and if speed is important you may want to use just `Trait::Env::Varaible`. 

AUTHOR
======

Simon Proctor <simon.proctor@gmail.com>

Thanks to Jonathan Worthington and Elizabeth Mattijsen for giving me the framework to build this on. Any mistakes are mine. 

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
