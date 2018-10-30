NAME
====

Config::Netrc - module for parsing of Netrc configuration files.

SYNOPSIS
========

```perl6
use Config::Netrc;
say Config::Netrc::parse-file('my-example.netrc');
```

DESCRIPTION
===========

There are basically two main functions: parse and parse-file. First function takes a string of netrc-file content and returns to you a hash with some signature or Nil value if parser failed.

This hash contains of two arrays: `comments` and `entries`. In the section comments you will get all comment strings(without leading `#`) and in the entries section you get array of hashes with this structure:

```
machine  => {value => val, comment => my-comment},
login    => {value => val, comment => my-comment},
password => {value => val, comment => my-comment}
```
Of course, login or password lines are optional and comment entry for lines like following:

```
machine val # my-comment
```
is also optional.

You will be able to use this hash to determine state of user's Netrc file state.

TODO
====
* Detection of user's config file at his `home` directory

COPYRIGHT
=========

This library is free software; you can redistribute it and/or modify it under the terms of the [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0)
