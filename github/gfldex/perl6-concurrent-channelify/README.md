# Concurrent::Channelify
[![Build Status](https://travis-ci.org/gfldex/perl6-concurrent-channelify.svg?branch=master)](https://travis-ci.org/gfldex/perl6-concurrent-channelify)

Turn a lazy list into an auto-threading lazy list.

# SYNOPSIS

```
use v6;
use Concurrent::Channelify;

my \l1 = (10_000_000..10_100_000).grep({.is-prime});

for my $c := channelify(l1) {
    $c.channel.close if $_ > 10_010_000;
    say $_
}

my \l2 = <a b c>;

for l2⇒ {
    say $_
}
```

# DESCRIPTION

## Routines

### sub channelify(Positional:D, :$no-thread = False)

Return a new lazy list that is turned into a `Channel`. If `no-thread` is
`True` do not start a thread to generate values. The environment variable
`RAKUDO_MAX_THREAD` with a value smaller then 2 has the same effect then
`no-thread`, if set before the use-statement is executed.

The channel can be accessed by calling the mixed in method `channel`. Closing
the channel will force the lazy list to stop producing values and kill the
associated thread.

To query if a thread was started call the mixed in method `no-thread`.

### postfix ⇒

see `sub channelify`

