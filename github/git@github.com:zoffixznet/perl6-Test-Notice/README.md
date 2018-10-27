[![Build Status](https://travis-ci.org/zoffixznet/perl6-Test-Notice.svg)](https://travis-ci.org/zoffixznet/perl6-Test-Notice)

# NAME

Test::Notice - Display noticable messages to users during tests

# SYNOPSIS

```perl6
    use Test::Notice;
    notice 'Install Foo::Bar::Baz for extra awesome features!';
```

# DESCRIPTION

This module lets you display highly visible messages to users during
the run of your test, pausing long enough for them to read it.

![](sample.png)

# EXPORTED SUBROUTINES

## `notice`

```perl6
    notice 'Install Foo::Bar::Baz for extra awesome features!';
```

Takes one mandatory argument: the string to display in the message.
Does not return anything meaningful. The message will be coloured if optional
`Terminal::ANSIColor` is installed. The output also pauses long enough
for an average reader to read the entire message (regardless of its length),
unless `NONINTERACTIVE_TESTING` environmental variable is set.

# LIMITATIONS

The current implementation always assumes the terminal width of 80 characters.
If you can figure out how to get the actual width when test is run with
`prove`, patches are more than welcome.

Currently, any amount of whitespace in the displayed message will be squashed
into a single space.

---

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Test-Notice

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Test-Notice/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
