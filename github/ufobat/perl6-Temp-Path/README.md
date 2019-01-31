[![Build Status](https://travis-ci.org/ufobat/perl6-Temp-Path.svg?branch=master)](https://travis-ci.org/ufobat/perl6-Temp-Path)

NAME
====

Temp::Path - Make a temporary path, file, or directory

SYNOPSIS
========

    use Temp::Path;

    with make-temp-path {
            .spurt: 'meows';
        say .slurp: :bin; # OUTPUT: «Buf[uint8]:0x<6d 65 6f 77 73>␤»
        say .absolute;    # OUTPUT: «/tmp/1E508EE56B7C069B7ABB7C71F2DE0A3CE40C20A1398B45535AF3694E39199E9A␤»
    }

    with make-temp-path :content<meows> :chmod<423> :suffix<.txt> {
        .slurp.say; # OUTPUT: «meows␤»
        .mode .say; # OUTPUT: «0647␤»
        say .absolute; # OUTPUT «/tmp/8E548EE56B7C119B7ABB7C71F2DE0A3CE40C20A1398B45535AF3694E39199EAE.txt␤»
    }

    with make-temp-dir {
        .add('meows').spurt: 'I ♥ Perl 6!';
        .dir.say; # OUTPUT: «("/tmp/B42F3C9D8B6A0C5C911EE24DD93DD213F1CE1DD0239263AC3A7D29A2073621A5/meows".IO)␤»
    }

    {
        temp $*TMPDIR = make-temp-dir :chmod<0o700>;
        $*TMPDIR.say;
        # OUTPUT:
        # "/tmp/F5AA112627DA7B59C038900A3C8C7CB05477DCCCEADF2DC447EC304017A1009E".IO

        say make-temp-path;
        # OUTPUT:
        # "/tmp/F5AA112627DA7B59C038900A3C8C7CB05477DCCCEADF2DC447EC304017A1009E/…
        # …C41E7114DD24C65C6722981F8C5693E762EBC5958238E23F7B324A1BDD37A541".IO
    }

EXPORTED TERMS
==============

This module exports terms (not subroutines), so you don't need to use parentheses to avoid block gobbling errors. Just use these same way as you'd use constant `π`

If you have to use parens for some reason, make them go around the whole them, not just the args:

    make-temp-path(:content<foo> :chmod<423>) # WRONG
    (make-temp-path :content<foo> :chmod<423>) # RIGHT

`make-temp-path`
----------------

Defined as:

    sub term:<make-temp-path> (
        :$content where Any|Blob:D|Cool:D,
        Int :$chmod,
        Str() :$prefix = '',
        Str() :$suffix = ''
        --> IO::Path:D
    )

Creates an [IO::Path](https://docs.perl6.org/type/IO::Path) object pointing to a path inside [$*TMPDIR](https://docs.perl6.org/language/variables#index-entry-%24%2ATMPDIR) that will be deleted (see [DETAILS OF DELETION](#details-of-deletion) section below).

Unless `:$chmod` or `:$content` are given, no files will be created. If `:$chmod` is given a file containing `:$content` (or empty, if no `:$content` is given) will be created with `$chmod` [permissions](https://docs.perl6.org/type/IO::Path#method_chmod). If `:$content` is given without `:$chmod`, the mode will be the default resulting from files created with [IO::Handle.open](https://docs.perl6.org/type/IO::Handle#method_open).

The [basename](https://docs.perl6.org/type/IO::Path#method_basename) of the path is currently a SHA256 hash, but your program should not make assumptions about the format of the basename.

**Security Note:** at the moment, `:chmod` is set *after* the file is created and its content is written. This will be fixed once a way to create a file with a specific mode is available in Rakudo. While it will work at the moment, it might not be the best idea to assume `:$content` will be successfully written if you set `:$chmod` that does not let the current process write to the file.

`make-temp-dir`
---------------

Defined as:

    sub term:<make-temp-dir> (Int :$chmod, Str() :$prefix = '', Str() :$suffix = '' --> IO::Path:D)

Creates a directory inside [$*TMPDIR](https://docs.perl6.org/language/variables#index-entry-%24%2ATMPDIR) that will be deleted (see [DETAILS OF DELETION](#details-of-deletion) section below) and returns the [IO::Path](https://docs.perl6.org/type/IO::Path) object pointing to it.

If `:$chmod` is provided, the directory will be created with that mode. Otherwise, the default `.mkdir` [mode](https://docs.perl6.org/type/IO::Path#routine_mkdir) will be used.

Note that currently `.mkdir` pays attention to [umask](https://en.wikipedia.org/wiki/Umask) and `make-temp-dir` will first the `:$chmod` to `.mkdir`, to create `umask` masked directory, and then it will [.chmod](https://docs.perl6.org/type/IO::Path#method_chmod) it, to remove the effects of the `umask`.

DETAILS OF DELETION
===================

The deletion of files created by this module will happen either when the returned `IO::Path` objects are garbage collected or when the `END` phaser gets run. Note that this means temporary files/directories may be left behind if your program crashes or gets aborted.

The temporary `IO::Path` objects created by `make-temp-path` and `make-temp-dir` terms have a role `Temp::Path::AutoDel` mixed in that will [rmtree](https://github.com/labster/p6-file-directory-tree#rmtree) or [.unlink](https://docs.perl6.org/type/IO::Path#routine_unlink) the filesystem object the path points to.

Note that deletion will happen only if the path was created by this module. For example doing `make-temp-dir.sibling: 'foo'` will still give you an `IO::Path` with `Temp::Path::AutoDel` mixed in due to how `IO::Path` methods create new objects. But new objects created by `.sibling`, `.add`, `.child`, `.parent`, etc won't be deleted, when the object gets garbage collected, because *you* created it and not the module. Of course, when a parent directory, that was created by this module gets deleted, all its contents that you created with `.child` gets removed from the disk. Siblings need to be removed manually.

REPOSITORY
==========

Fork this module on GitHub: https://github.com/ufobat/perl6-Temp-Path

BUGS
====

To report bugs or request features, please use https://github.com/ufobat/perl6-Temp-Path/issues

AUTHOR
======

  * Zoffix Znet (http://perl6.party/)

  * Martin Barth (ufobat)

LICENSE
=======

You can use and distribute this module under the terms of the The Artistic License 2.0. See the LICENSE file included in this distribution for complete details.

The META6.json file of this distribution may be distributed and modified without restrictions or attribution.

