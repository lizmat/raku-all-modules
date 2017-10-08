[![Build Status](https://travis-ci.org/zoffixznet/perl6-IO-Dir.svg)](https://travis-ci.org/zoffixznet/perl6-IO-Dir)

# NAME

IO::Dir - IO::Path.dir you can close

# SYNOPSIS

```perl6
    # Won't always suit, since non-exhausted iterator holds on to an open
    # file descriptor until GC:
    'foo'.IO.dir[^3].say;

    # all good; we explicitly close the file descriptor when done
    .dir[^3].say and .close with IO::Dir.open: 'foo';
```

# DESCRIPTION

[`IO::Path.dir`](https://docs.perl6.org/routine/dir) does the job well for
most cases, however, there's an edge case where it's no good:

- You don't exhaust or [eagerly](https://docs.perl6.org/routine/eager)
    evaluate the `Seq` `dir` returns
- You do that enough times in some tight loop that
[GC](https://en.wikipedia.org/wiki/Garbage_collection_(computer_science))
doesn't get a chance to clean up unreachable `dir` `Seq`s; or
- You run this on some system with tight open file limits

If you're in that category, then good news! `IO::Dir` gives you a `dir` whose
file descriptor you can close without relying on GC or having to [fully
reify](https://docs.perl6.org/language/glossary#index-entry-Reify)
the dir's `Seq`.

# METHODS

## `.new`

Creates a new `IO::Dir` object. Takes no args.

## `.open`

Opens for reading directory given as a positional argument, which can be
any object that can be coerced to `IO::Path` via `.IO` method. Defaults to
opening `'.'` directory.

Will first `.close` the invocant if it was previously opened.

```perl6
    $dir1.open;
    $dir2.open: 'foo';
```

## `.dir`

Takes similar arguments as
[`IO::Path.dir`](https://docs.perl6.org/routine/dir), that have the same
meaning, returning the same type of `Seq`. Will `.close` the invocant when
the result is exhausted.

The additional arguments are boolean `:absolute` and `:Str` that control whether to return absolute paths when dir was opened via an absolute path and whether to
return paths as `IO::Path` or `Str` objects.

**Note:** you cannot call `.dir` more than once; re-open the
invocant or create a new `IO::Dir` if you need that. Will die if called on
an un-opened `IO::Dir`.

```perl6
    # Explicit close:
    .dir[^3].say and .close with IO::Dir.open: 'foo';

    # Implicit close (arrays are mostly-eager, so our Seq is exhausted here)
    my @files = IO::Dir.open('foo').dir;
```

## `.close`

Closes an open `IO::Dir`, freeing the file descriptor.

```perl6
    .dir[^3].say and .close with IO::Dir.open: 'foo';
```

----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-IO-Dir

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-IO-Dir/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
