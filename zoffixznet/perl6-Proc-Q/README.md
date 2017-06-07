[![Build Status](https://travis-ci.org/zoffixznet/perl6-Proc-Q.svg)](https://travis-ci.org/zoffixznet/perl6-Proc-Q)

# NAME

Proc::Q - Queue up and run a herd of Procs

# TABLE OF CONTENTS
- [SYNOPSIS](#synopsis)
- [DESCRIPTION](#description)
- [EXPORTED SUBROUTINES AND TYPES](#exported-subroutines-and-types)
    - [`proc-q`](#proc-q)
        - [`+@commands`](#commands)
        - [`:@tags`](#tags)
        - [`:@in`](#in)
        - [`:$batch`](#batch)
        - [`:$timeout`](#timeout)
        - [`:$out`](#out)
        - [`:$err`](#err)
        - [`:$merge`](#merge)
    - [`Proc::Q::Res`](#procqres)
        - [`.tag`](#tag)
        - [`.out`](#out-1)
        - [`.err`](#err-1)
        - [`.merged`](#merged)
        - [`.exitcode`](#exitcode)
        - [`.killed`](#killed)
- [REPOSITORY](#repository)
- [BUGS](#bugs)
- [AUTHOR](#author)
- [LICENSE](#license)

# SYNOPSIS

```perl6
use Proc::Q;

# Run 26 procs; each receiving stuff on STDIN and putting stuff out to STDOUT,
# as well as sleeping for increasingly long periods of time. The timeout
# of 3 seconds will kill all the procs that sleep longer than that.

my @stuff = 'a'..'z';
my $proc-chan = proc-q
             @stuff.map({«perl6 -e "print '$_' ~ \$*IN.slurp; sleep {$++/5}"»}),
  tags    => @stuff.map('Letter ' ~ *),
  in      => @stuff.map(*.uc),
  timeout => 3;

react whenever $proc-chan {
    say "Got a result for {.tag}: STDOUT: {.out}"
        ~ (". Killed due to timeout" if .killed)
}

# OUTPUT:
# Got a result for Letter a: STDOUT: aA
# Got a result for Letter b: STDOUT: bB
# Got a result for Letter c: STDOUT: cC
# Got a result for Letter d: STDOUT: dD
# Got a result for Letter e: STDOUT: eE
# Got a result for Letter f: STDOUT: fF
# Got a result for Letter g: STDOUT: gG
# Got a result for Letter h: STDOUT: hH
# Got a result for Letter i: STDOUT: iI
# Got a result for Letter j: STDOUT: jJ
# Got a result for Letter k: STDOUT: kK
# Got a result for Letter l: STDOUT: lL
# Got a result for Letter m: STDOUT: mM
# Got a result for Letter n: STDOUT: nN
# Got a result for Letter o: STDOUT: oO. Killed due to timeout
# Got a result for Letter p: STDOUT: pP. Killed due to timeout
# Got a result for Letter s: STDOUT: sS. Killed due to timeout
# Got a result for Letter t: STDOUT: tT. Killed due to timeout
# Got a result for Letter v: STDOUT: vV. Killed due to timeout
# Got a result for Letter w: STDOUT: wW. Killed due to timeout
# Got a result for Letter q: STDOUT: qQ. Killed due to timeout
# Got a result for Letter r: STDOUT: rR. Killed due to timeout
# Got a result for Letter u: STDOUT: uU. Killed due to timeout
# Got a result for Letter x: STDOUT: xX. Killed due to timeout
# Got a result for Letter y: STDOUT: yY. Killed due to timeout
# Got a result for Letter z: STDOUT: zZ. Killed due to timeout
```

# DESCRIPTION

**Requires Rakudo 2017.06 or newer.**

Got a bunch of [Procs](https://docs.perl6.org/type/Proc) you want to queue up
and run, preferably with some timeout for Procs that get stuck? Well, good news!

# EXPORTED SUBROUTINES AND TYPES

## `proc-q`

Defined as:

```perl6
    sub proc-q (
        +@commands where .so && .all ~~ List & .so,

                :@tags where .elems == @commands = @commands,
                :@in   where {
                    .elems == @commands|0
                    and all .map: {$_ ~~ Cool:D|Blob:D|Nil or $_ === Any}
                } = (Nil xx @commands).List,
        Numeric :$timeout where .DEFINITE.not || $_ > 0,
        UInt:D  :$batch   where .so = 8,
                :$out     where Bool:D|'bin' = True,
                :$err     where Bool:D|'bin' = True,
        Bool:D  :$merge   where .not | .so & (
                  $out & $err & (
                      ($err eq 'bin' & $out eq 'bin')
                    | ($err ne 'bin' & $out ne 'bin'))) = False,

        --> Channel:D
    )
```

See SYNOPSIS for sample use.

Returns a [`Channel`](https://docs.perl6.org/type/Channel) of `Proc::Q::Res`
objects. Batches the `@commands` in batches of `$batch` and runs those via
in parallel, optionally feeding STDIN with corresponding data from
`@in`, as well as capturing STDOUT/STDERR, and [killing the
process](https://docs.perl6.org/type/Proc::Async#method_kill) after
`$timeout`, if specified.

Arguments are as follows:

### `+@commands`

A list of lists, where each of inner lists is a list of arguments to
[`Proc::Async.new`](https://docs.perl6.org/type/Proc::Async#method_new). You
do not need to specify the `:w` argument, and if you do, its value will be
ignored.

Must have at least one list of commands inside `@commands`

### `:@tags`

To make it possible to match the input with the output, you can 'tag' each
of the commands in `@commands` by specifying the value via `@tags` argument
at the same index as the command is at. The given tag will be available via
`.tag` method of the `Proc::Q::Res` object responsible.
Any object can be used as a tag. If `:@tags` is provided, it must have the same
number of elements as `+@commands` argument. If it's not provided, it defaults
to `@commands`.

### `:@in`

Optionally, you can send stuff to STDIN of your procs, by giving a `Blob` or
`Str` in `:@in` arg at the same index as the the index of the command for that
proc in `@commands`. If specified, the number of elements in `@in` must be the
same as number of elements in `@commands`. Specify undefined value to avoid
sending STDIN to a particular proc.

TIP: is your queue hanging for some reason? Ensure the procs you're running
arent's sitting and waiting for STDIN. Try passing an empty strings in `:@in`.

### `:$batch`

Takes a positive `Int`. Defaults to `8`. Specifies how many `@commands`
to run at the same time.

### `:$timeout`

By default is not specified.
Takes a positive `Numeric` specifying the number of seconds after which
a proc should be killed, if it did not complete yet. Timer starts ticking once
the proc is [`.ready`](https://docs.perl6.org/type/Proc::Async#method_ready).
The process is killed with `SIGTERM` signal and if after 1 second it's still
alive, it gets another kill with `SIGSEGV`.

### `:$out`

Defaults to `True`.
If set to `True` or string `'bin'`, the routine will capture STDOUT from the
procs, and make it available in `.out` method of `Proc::Q::Res` object. If set
to string `'bin'`, the output will be captured in binary and `.out` method will
contain a `Blob` instead of `Str`

### `:$err`

Same as `:$out` except as applied to procs' STDERR.

### `:$merge`

Defaults to `False`.
If set to `True`, both `:$err` and `:$out` must be set to `True` or both set to
string `'bin'`.
If set to `True`, the `.merged` method will contain the merged output of
STDOUT and STDERR (so it'll be a `Str` or, if the `:$out`/`:$err` are set to
`'bin'`, a `Blob`).

**Note** that there's no order guarantee. Output from a proc sent to STDERR
after output to STDOUT, might end up *before* STDOUT's data in `.merged` object.

## `Proc::Q::Res`

Each of the item sent to the `Channel` from `proc-q` routine will be
a `Proc::Q::Res` object (technically, it might also be an `Exception` object
if something explodes while trying to launch and wait for a proc, but it's of
the "should never happen" variety; the `Exception` will be the reason why
stuff exploded).

While the `@commands` to be executed will be batched in `:$batch` items, the
order within batches is not guaranteed. Use `:@tags` to match the
`Proc::Q::Res` to the input commands.

The `Proc::Q::Res` type contains information about the proc that was ran and
provides these methods:

### `.tag`

The same object that was given as a tag via `:@tags` argument (by default,
the command from `@commands` that was executed). The purpose of the `.tag`
is to match this `Proc::Q::Res` object to the proc you ran.

### `.out`

Contains a `Stringy` with STDOUT of the proc if `:$out` argument to `proc-q` is
set to a true value.

### `.err`

Contains a `Stringy` with STDERR of the proc if `:$err` argument to `proc-q` is
set to a true value.

### `.merged`

Contains a `Stringy` with merged STDOUT and STDERR of the proc if `:$merge`
argument to `proc-q` is set to a true value. Note that even when `:$merge` is in
use, the `.out` and `.err` methods will contain the separated streams.

### `.exitcode`

Contains [the exit code](https://docs.perl6.org/type/Proc#method_exitcode) of
the executed proc.

### `.killed`

A `Bool:D` that is `True` if this proc was killed due to the `:$timeout`. More
precisely, this is an indication that the timeout expired and the kill code
started to run. It *is* possible for a proc to successfully complete in this
small window opportunity between the attribute being set and the signal from
[`.kill`](https://docs.perl6.org/type/Proc::Async#method_kill)
being received by the process

----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Proc-Q

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Proc-Q/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
