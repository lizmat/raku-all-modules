[![Build Status](https://travis-ci.org/zoffixznet/perl6-Subset-Helper.svg)](https://travis-ci.org/zoffixznet/perl6-Subset-Helper)

# NAME

Subset::Helper - create awesome subsets

# SYNOPSIS

```perl6
    use Subset::Helper;

    subset Positive of Int
        where subset-is * > 0, 'Value must be above zero';

    my Positive $x = 42; # success
    my Positive $x = -2; # Fails with 'Value must be above zero';
```

# DESCRIPTION

This module solves two inconviniences with Perl 6's subsets:

    1) Display of useful error messages when type check fails
    2) Avoid evaluating subset's condition for `Any` values,
        which is what happens with optional parameters

# EXPORTED SUBROUTINES

## `subset-is`

```perl6
    subset Positive of Int where subset-is * > 0;

    subset RoverCam of Str where subset-is
        { $_ ∈ set <MAST CHEMCAM FHAZ RHAZ> },
        'Valid cameras are MAST, CHEMCAM, FHAZ, and RHAZ';
```

Takes one mandatory positional argument, which is the
code to execute to check the validity of value, and an
optional descriptive error message to show when the value
doesn't match the subset.

Note: undefined values are accepted by the subset.
This exists to make it possible to cleanly define subsets
for optional parameters, for which the type check is still
called, even when they aren't provided in the sub/method calls.

# CONFUSING ERRORS

You can't declare our scoped subsets within roles. If you're
using this module, however, that error will instead point
to the end of the declaration, saying `expecting any of: postfix`.
Simply prefix your subset with `my`

# BUGS AND LIMITATIONS

Rakudo may evaluate whether a value matches the subset TWICE:
once to check the match and once to get sensible error information.

Thus, currently the error message you provide is printed twice.

Patches to fix this are welcome.

----

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Subset-Helper

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Subset-Helper/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
