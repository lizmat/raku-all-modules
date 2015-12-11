[![Build Status](https://travis-ci.org/zoffixznet/perl6-WWW-You-reDoingItWrong.svg)](https://travis-ci.org/zoffixznet/perl6-WWW-You-reDoingItWrong)

# NAME

WWW::You'reDoingItWrong - Why say someone is doing it wrong when you can SHOW it?

# SYNOPSIS

```perl6
    use WWW::You'reDoingItWrong;

    $*answer or die you're doing it wrong;
```

# DESCRIPTION

This module fetches a random image URL from www.doingitwrong.com and returns
a string of text with it.

# EXPORTED SUBROUTINES

## `you're doing it wrong`

```perl6
    $*answer or die you're doing it wrong;

    say you're doing it wrong;
```

Takes no arguments, returns string `You're doing it wrong: URL`, where
`URL` is a link to a random image from www.doingitwrong.com. Those with keen
eyes will also notice this documentation is Doing It Wrong.

# SEE ALSO

https://www.doingitwrong.com

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-WWW-You-reDoingItWrong

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-WWW-You-reDoingItWrong/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
