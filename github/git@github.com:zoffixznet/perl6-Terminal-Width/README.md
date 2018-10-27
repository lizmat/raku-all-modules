[![Build Status](https://travis-ci.org/zoffixznet/perl6-Terminal-Width.svg)](https://travis-ci.org/zoffixznet/perl6-Terminal-Width)

# NAME

Terminal::Width - Get the current width of the terminal

# SYNOPSIS

```perl6
    use Terminal::Width;

    # Default to 80 characters if we fail to get actual width:
    my $width = terminal-width;

    # Default to 100 characters if we fail to get actual width:
    $width = terminal-width :default<100>;

    # return a Failure if we fail to get actual width:
    $width = terminal-width :default<0>;
```

# DESCRIPTION

This module tries to figure out the current width of the terminal the
program is running in. The module is known to work on Windows 10 command
prompt and Debian flavours of Linux. Untested on other systems, but should also
work on OSX.

# EXPORTED SUBROUTINES

## `terminal-width`

```perl6
    terminal-width (Int :$default = 80 --> Int|Failure)
```

Returns and `Int` representing the character width of the terminal.
Takes one optional named argument `:default` that specifies the width
to use if we fail to determine the actual width (defaults to `80`). If
`:default` is set to `0` the subroutine will return a `Failure` if it
can't determine the width.

# ⚠ SECURITY NOTE

On Windows, this module attempts to run program `mode` and on all other
systems it attempts to run `tput`. A clever attacker can manipulate what
the actual executed program is, resulting in it being executed
with the privileges of your script's user.

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Terminal-Width

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Terminal-Width/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
