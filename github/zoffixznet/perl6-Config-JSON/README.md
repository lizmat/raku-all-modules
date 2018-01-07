[![Build Status](https://travis-ci.org/zoffixznet/perl6-Config-JSON.svg)](https://travis-ci.org/zoffixznet/perl6-Config-JSON)

# NAME

Config::JSON - flat, JSON-backed read-write configuration

# TABLE OF CONTENTS
- [SYNOPSIS](#synopsis)
- [DESCRIPTION](#description)
- [SINGLE CONFIG FILE MODE](#single-config-file-mode)
    - [EXPORTED SUBROUTINES](#exported-subroutines)
        - [`jconf`](#jconf)
        - [`jconf-write`](#jconf-write)
- [PER-CALL CONFIG FILE MODE](#per-call-config-file-mode)
    - [EXPORTED SUBROUTINES](#exported-subroutines-1)
        - [`jconf`](#jconf-1)
        - [`jconf-write`](#jconf-write-1)
- [EXCEPTIONS](#exceptions)
    - [`Config::JSON::X::NoSuchKey`](#configjsonxnosuchkey)
    - [`Config::JSON::X::Open`](#configjsonxopen)
- [MULTI-THREAD/PROCESS SAFETY](#multi-threadprocess-safety)
- [CAVEATS](#caveats)
- [REPOSITORY](#repository)
- [BUGS](#bugs)
- [AUTHOR](#author)
- [LICENSE](#license)

# SYNOPSIS

```perl6
    use Config::JSON; # uses './config.json' by default

    say jconf('foo')//'no such option'; # "no such option"

    saw jconf-write('foo', 'bar');
    say jconf 'foo'; # "bar"

    saw jconf-write('foo', {bar => [<a b c>]});
    say jconf('foo').perl; # ${:bar($["a", "b", "c"])}
```

Custom config files:

```perl6
    use Config::JSON 'meow.json';
    say jconf 'foo';
```

```perl6
    use Config::JSON '';  # <-- empty string is required
    say jconf 'meow.json'.IO, 'foo'; # specify file during calls
```

# DESCRIPTION

Simple read-write configuration, using JSON saved in a file. By design, the
API provides flat key/value structure only, but you're free to save nested
structures under the keys.

# SINGLE CONFIG FILE MODE

The configuration file to use is specified on the `use` line:

```perl6
    use Config::JSON;               # default './config.json'
    use Config::JSON 'foo.json';    # custom './foo.json'
    use Config::JSON 'foo.json'.IO; # also OK
```

If the file doesn't exist, it will be automatically created. If you wish to
create it manually, its outer data structure must be a JSON object:

```perl6
    constant $file = 'foo.json'.IO;
    BEGIN $file.spurt: '{ "meow": 42 }';
    use Config::JSON $file;
    say jconf 'meow'; # 42
```

## EXPORTED SUBROUTINES

### `jconf`

```perl6
    multi jconf (Whatever --> Mu);
    multi jconf (Str:D $key --> Mu);
```

Reads config file and looks up `$key` in the config hash. Returns its value
if it `:exists`, otherwise, [`fail`s](https://docs.perl6.org/routine/fail)
with `Config::JSON::X::NoSuchKey` exception. If `$key` is `Whatever`, returns
the entire config hash.

If config file could not be read, [`fail`s](https://docs.perl6.org/routine/fail)
with `Config::JSON::X::Open` exception.

### `jconf-write`

```perl6
    sub jconf-write (Str:D $key, Mu $value --> Nil);
```

Saves `$value` under `$key`, possibly overwriting previously-existing value.
Reads the config from file before writing.

If config file could not be read or written,
[`fail`s](https://docs.perl6.org/routine/fail)
with `Config::JSON::X::Open` exception.

# PER-CALL CONFIG FILE MODE

```
    use Config::JSON '';  # no auto config file; pass filename to each call
                          # of config read/write routines instead
```

## EXPORTED SUBROUTINES

Note that these are **not** available in single-config-file mode.

### `jconf`

```perl6
    multi jconf (IO::Path:D $file, Whatever --> Mu);
    multi jconf (IO::Path:D $file, Str:D $key --> Mu);
```

Same as `jconf` for single-config-file version, except takes the
name of the config file as the first argument.

### `jconf-write`

```perl6
    sub jconf-write (IO::Path:D $file, Str:D $key, Mu $value --> Nil);
```

Same as `jconf-write` for single-config-file mode, except takes the
name of the config file as the first argument.

# EXCEPTIONS

## `Config::JSON::X::NoSuchKey`

```perl6
    has Str:D      $.key  is required;
    has IO::Path:D $.file is required;
    method message {
        "Key `$!key` is not present in the config file `$!file.absolute()`"
    }
```

## `Config::JSON::X::Open`

```perl6
    has Exception:D $.e    is required;
    has IO::Path:D  $.file is required;
    method message {
        "Received $!e.^name() with message `$!e.message()` while trying to"
        ~ " open config file `$!file.absolute()`"
    }
```

# MULTI-THREAD/PROCESS SAFETY

The routines perform advisory locking of the config file on each read and write.

# CAVEATS

Rakudo's bug [R#1370](https://github.com/rakudo/rakudo/issues/1370) prevents
use of this module in precompiled modules when using default config file
or specifying one on the `use` line. Use `no precompilation`
pragma to work-around it.

Using empty string on `use` line and specifying config file's name to each
routine does not trigger this bug.

-----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Benchy

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Benchy/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
