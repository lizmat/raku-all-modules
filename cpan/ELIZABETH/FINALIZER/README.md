[![Build Status](https://travis-ci.org/lizmat/FINALIZER.svg?branch=master)](https://travis-ci.org/lizmat/FINALIZER)

NAME
====

FINALIZER - dynamic finalizing for objects that need finalizing

SYNOPSIS
========

    {
        use FINALIZER;   # enable finalizing for this scope
        my $foo = Foo.new(...);
        # do stuff with $foo
    }
    # $foo has been finalized by exiting the above scope

    # different file / module
    use FINALIZER <class-only>;   # only get the FINALIZER class
    class Foo {
        has &!unregister;

        submethod TWEAK() {
            &!unregister = FINALIZER.register: { .finalize with self }
        }
        method finalize() {
            &!unregister();  # make sure there's no registration anymore
            # do whatever we need to finalize, e.g. close db connection
        }
    }

DESCRIPTION
===========

FINALIZER allows one to register finalization of objects in the scope that you want, rather than in the scope where objects were created (like one would otherwise do with `LEAVE` blocks or the `is leave` trait).

AS A MODULE DEVELOPER
=====================

If you are a module developer, you need to use the FINALIZE module in your code. In any logic that returns an object (typically the `new` method) that you want finalized at the moment the client decides, you register a code block to be executed when the object should be finalized. Typically that looks something like:

    use FINALIZER <class-only>;  # only get the FINALIZER class
    class Foo {
        has &!unregister;

        submethod TWEAK() {
            &!unregister = FINALIZER.register: { .finalize with self }
        }
        method finalize() {
            &!unregister();  # make sure there's no registration anymore
            # do whatever we need to finalize, e.g. close db connection
        }
    }

AS A PROGRAM DEVELOPER
======================

Just use the module in the scope you want to have objects finalized for when that scope is left. If you don't use the module at all, all objects that have been registered for finalization, will be finalized when the program exits. If you want to have finalization happen for some scope, just add `use FINALIZER` in that scope. This could e.g. be used inside `start` blocks, to make sure all registered resources of a job run in another thread, are finalized:

    await start {
        use FINALIZE;
        # open database handles, shared memory, whatever
        my $foo = Foo.new(...);
    }   # all finalized after the job is finished

RELATION TO DESTROY METHOD
==========================

This module has **no** direct connection with the `.DESTROY` method functionality in Perl 6. However, if you, as a module developer, use this module, you do not need to supply a `DESTROY` method as well, as the finalization will have been done by the `FINALIZER` module. And as the finalizer code that you have registered, will keep the object otherwise alive until the program exits.

It therefore makes sense to reset the variable in the code doing the finalization. For instance, in the above class Foo:

    method finalize(\SELF: --> Nil) {
        # do stuff with SELF
        SELF = Nil
    }

The `\SELF:` is a way to get the invocant without it being decontainerized. This allows resetting the variable containing the object (by assigning `Nil` to it).

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/FINALIZER . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

