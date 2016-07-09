[![Build Status](https://travis-ci.org/zoffixznet/perl6-Pretty-Topic.svg)](https://travis-ci.org/zoffixznet/perl6-Pretty-Topic)

# NAME

Pretty::Topic - Alias `$_` topical variable to something prettier

# SYNOPSIS

```perl6
use Pretty::Topic '♥';

say ^4 .map: { $_ + 10 }; # fugly
say ^4 .map: { ♥  + 10 }; # purty!

given <meow woof>.pick  {
    when ♥ ~~ /meo/ { say 'Tis a kitty!' }
    when ♥ ~~ /oof/ { say 'Tis a doggy!' }
}
```

Multi-char alias is fine too:
```perl6
use Pretty::Topic 'TOPIC-VAR';

say ^4 .map: { TOPIC-VAR + 10 };
```

# DESCRIPTION

This module aliases the `$_` topical variable to a string you provide on the
`use` line, allowing you to avoid the eyesore the `$_` is.

# EXPORTS

This module exports the string you provide on the `use` line as a `&term:<>`.

# LIMITATIONS

The current implementation doesn't let you use `<` or `>` in topic's name.
Open an Issue if you really really need that feature.

----

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Pretty-Topic

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Pretty-Topic/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
