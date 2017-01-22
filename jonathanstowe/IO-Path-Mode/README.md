# IO::Path::Mode

Augment Perl 6's IO::Path with a .mode() method to get the file mode

## Synopsis

```perl6

use IO::Path::Mode;

my $mode = "some-file".IO.mode;

say $mode.set-user-id ?? 'setuid' !! 'not setuid';

say $mode.user.execute ?? 'executable' !! 'not executable';

say $mode.file-type == IO::Path::Mode::File ?? 'file' !! 'something other than a normal file';

...


```

## Description

This augments the type ```IO::Path``` to provide a ```.mode``` method
that allows you to get at the file permissions (or mode.)  It follows
the POSIX model pf user, group and other permissions and consequently
may not make a meaningful result on e.g. Windows (although the underlying
calls appear to return something approximating the correct answer.)

If you have a more recent rakudo that provides a ```mode``` method, it
will replace that method with one that returns an ```IO::Path::Mode```
object rather than an ```IntStr```, this is a transitional arrangement
and will be deprecated in a future release in favour of a different
method name.

It relies on some non-specified functionality in the VM so may probably
only work with Rakudo on MoarVM.

This is mostly provided as some relief for not having the functionality
directly exposed in Rakudo and as a discussion board for the best way
of implementing the functionality going forward.

## Installation

Assuming you have a working Rakudo Perl 6 installation you should be able to
install this with *panda* :

    # From the source directory
   
    panda install .

    # Remote installation

    panda install IO::Path::Mode

This should work equally well with *zef* but I just haven't tested it.

## Support

I welcome suggestions, patches and bug reports at:

   https://github.com/jonathanstowe/IO-Path-Mode

I'd be particularly interested in suggestions relating to making
the mode mutable and adding a multi candidate for 'chmod' that
can take an ```IO::Path::Mode``` object/

## Licence

This is free software.

Please see the [LICENCE](LICENCE) file in the distribution

© Jonathan Stowe 2016, 2017
