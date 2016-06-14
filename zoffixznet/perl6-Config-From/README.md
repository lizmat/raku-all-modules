[![Build Status](https://travis-ci.org/zoffixznet/perl6-Config-From.svg)](https://travis-ci.org/zoffixznet/perl6-Config-From)

# NAME

Config::From - Load configuration from file to variables via traits

# SYNOPSIS

JSON config file `my-config.json`:

```json
{
    "user"  : "zoffix",
    "pass"  : "s3cret",
    "groups": [ "foo", "bar", "ber" ]
}
```

Program that uses it:

```perl6
use Config::From 'my-config.json'; # config file defaults to 'config.json'

# automatically load variables from config
my $user   is from-config;
my $pass   is from-config;
my @groups is from-config;

say "$user\'s password is $pass and they belong to @groups[]";
# Prints: zoffix's password is s3cret and they belong to foo, bar, ber
```

# DESCRIPTION

This module lets you load a configuration file (in JSON format) and assign
values from it to variables using traits.

# EXPORTED TRAITS

# `is from-config`

```perl6
my $user         is from-config;
my @groups       is from-config;
my %replacements is from-config;
```

Tells the variable to get its values from the config file. The name of the
variable will be used as the name of the key in the top-level object of the
JSON config file.

The `@` and `%` sigils on variables will coerce the JSON value into
array or hash, respectively.

# LIMITATIONS

Current implementation does not allow use of more than one configuration
file per application and only lets you access values in a top-level object.

This may change in the future, if there's demand for such features.

----

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Config-From

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Config-From/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
