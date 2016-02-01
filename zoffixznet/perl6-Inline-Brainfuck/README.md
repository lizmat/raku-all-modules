[![Build Status](https://travis-ci.org/zoffixznet/perl6-Inline-Brainfuck.svg)](https://travis-ci.org/zoffixznet/perl6-Inline-Brainfuck)

# NAME

Inline::Brainfuck - Use Brainfuck language in your Perl 6 programs

# SYNOPSIS

```perl6
use lib 'lib';
use Inline::Brainfuck;

brainfuck '++++++++++ ++++++++++ ++++++++++ +++.'; # prints "!"
```

# DESCRIPTION

This module provides a subroutine that takes a string with
[Brainfuck code](https://en.wikipedia.org/wiki/Brainfuck) and executes it.

# EXPORTED SUBROUTINES

## `brainfuck`

```perl6
    brainfuck '++++++++++ ++++++++++ ++++++++++ +++.'; # prints "!"
```

Takes an `Str` with Brainfuck code to execute. Input will be read
from STDIN. The terminal will be switched to non-buffered mode, so any input
will be processed immediatelly, per-character. Output will be sent to STDOUT.

----

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Inline-Brainfuck

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Inline-Brainfuck/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
