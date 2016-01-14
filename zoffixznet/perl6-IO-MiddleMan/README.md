[![Build Status](https://travis-ci.org/zoffixznet/perl6-IO-MiddleMan.svg)](https://travis-ci.org/zoffixznet/perl6-IO-MiddleMan)

# NAME

IO::MiddleMan - hijack, capture, or mute writes to an IO::Handle

# TABLE OF CONTENTS
- [NAME](#name)
- [SYNOPSIS](#synopsis)
- [DESCRIPTION](#description)
- [ACCESSORS](#accessors)
    - [`.data`](#data)
    - [`.handle`](#handle)
    - [`.mode`](#mode)
- [METHODS](#methods)
    - [`.capture`](#capture)
    - [`.hijack`](#hijack)
    - [`.mute`](#mute)
    - [`.normal`](#normal)
    - [`.Str`](#str)
- [CAVEATS](#caveats)
- [REPOSITORY](#repository)
- [BUGS](#bugs)
- [AUTHOR](#author)
- [LICENSE](#license)

# SYNOPSIS

```perl6
    my $mm = IO::MiddleMan.hijack: $*OUT;
    say "Can't see this yet!";
    $mm.mode = 'normal';
    say "Want to see what I said?";
    say "Well, fine. I said $mm";

    my $fh = 'some-file'.IO.open: :w;
    my $mm = IO::MiddleMan.capture: $fh;
    $fh.say: 'test', 42;
    say "We wrote $mm into some-file";

    IO::MiddleMan.mute: $*ERR;
    note "you'll never see this!";
```

# DESCRIPTION

This module allows you to inject yourself in the middle between an `IO::Handle`
and things writing into it. You can completely hijack the data, merely capture
it, or discard it entirely.

# ACCESSORS

## `.data`

```perl6
    say Currently captured things are " $mm.data.join: '';

    $mm.data = () unless $mm.data.grep: {/secrets/};
    say "Haven't seen any secrets yet. Restarted the capture";
```

An array that contains data captured by [`.hijack`](#hijack) and
[`.capture`](#capture) methods. Each operation on the filehandle add one
element to `.data`; those operations are calls to `.print`, `.print-nl`,
`.say`, and `.put` methods on the original filehandle. Note that `.data`
added with `.say`/`.put` will have `\n` added to it already.

## `.handle`

```perl6
    my $mm = IO::MiddleMan.mute: $*OUT;
    say "This is muted";
    $mm.handle.say: "But this still works!";
```

The original `IO::Handle`. You can still successfully call data methods on it,
and no captures will be done, regardless of what the `IO::MiddleMan`
[`.mode`](#mode) is.

## `.mode`

```perl6
    my $mm = IO::MiddleMan.hijack: $*OUT;
    say "I'm hijacked!";
    $mm.mode = 'normal';
    say "Now things are back to normal";
```

Sets operational mode for the `IO::MiddleMan`. Valid modes are
[`capture`](#capture), [`hijack`](#hijack), [`mute`](#mute), and
[`normal`](#normal). See methods of the corresponding name for the
description of the behavior these modes enable.

# METHODS

## `.capture`

```perl6
    my $mm = IO::MiddleMan.capture: $*OUT;
    say "I'm watching you";
```

Creates and returns a new `IO::MiddleMan` object set to capture all the data
sent to the `IO::Handle` given as the positional argument. Any writes to the
original `IO::Handle` will proceed as normal, while also being stored in
[`.data` accessor](#data).

## `.hijack`

```perl6
    my $mm = IO::MiddleMan.hijack: $*OUT;
    say "Can't see this yet!";
```

Creates and returns a new `IO::MiddleMan` object set to hijack all the data
sent to the `IO::Handle` given as the positional argument. Any writes to the
original `IO::Handle` will NOT reach it and instead will be stored in
[`.data` accessor](#data).

## `.mute`

```perl6
    my $mm = IO::MiddleMan.mute: $*OUT;
    say "You'll never see this!";
```

Creates and returns a new `IO::MiddleMan` object set to ignore all the data
sent to the `IO::Handle` given as the positional argument.

## `.normal`

```perl6
    my $mm = IO::MiddleMan.normal: $*OUT;
    say "Things look perfectly normal";
```

Creates and returns a new `IO::MiddleMan` object set to send all the data
sent to the `IO::Handle` given as the positional argument as it normally would
and no capturing of it is to be done.

## `.Str`

```perl6
    say "Captured $mm";
```

This module overrides the `.Str` method to return all the
[captured data](#data) as a string.

# CAVEATS

The module currently only operates on non-binary data (i.e. `write` method
is still native to `IO::Handle`). Patches are welcome.

The given filehandle must be a writable container and its contents will
be changed to the `IO::MiddleMan` object, thus possibly complicating some
operations.

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-IO-MiddleMan

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-IO-MiddleMan/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
