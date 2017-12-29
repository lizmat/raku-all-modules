[![Build Status](https://travis-ci.org/zoffixznet/perl6-WWW-P6lert.svg)](https://travis-ci.org/zoffixznet/perl6-WWW-P6lert)

# NAME

`WWW::P6lert` - Implementation of [alerts.perl6.org](https://alerts.perl6.org) API

# TABLE OF CONTENTS
- [NAME](#name)
- [SYNOPSIS](#synopsis)
- [DESCRIPTION](#description)
- [TESTING](#testing)
- [ATTRIBUTES](#attributes)
    - [`.api-url`](#api-url)
- [CONSTRUCTOR](#constructor)
    - [`.new`](#new)
- [METHODS](#methods)
    - [`.all`](#all)
    - [`.last`](#last)
    - [`.since`](#since)
    - [`.alert`](#alert)
- [`WWW::P6lert::Alert` object](#wwwp6lertalert-object)
    - [ATTRIBUTES](#attributes-1)
        - [`.id`](#id)
        - [`.alert`](#alert-1)
        - [`.time`](#time)
        - [`.creator`](#creator)
        - [`.affects`](#affects)
        - [`.alert`](#alert-2)
- [REPOSITORY](#repository)
- [BUGS](#bugs)
- [AUTHOR](#author)
- [LICENSE](#license)

# SYNOPSIS

Alerts fetcher that keeps track of when it last fetched alerts:

```perl6
    use WWW::P6lert;

    my $conf := $*HOME.add: '.last-p6lert.data';
    my $last-time := +(slurp $conf orelse 0);

    with WWW::P6lert.new.since: $last-time {
        $conf.spurt: DateTime.now.Instant.to-posix.head.Int;
        say "Saved last fetch time to $conf.absolute()\n";

        for @^alerts {
            say join ' | ', "ID#{.id}", DateTime.new(.time),
                "severity: {.severity}";
            say join ' | ', ("affects: {.affects}" if .affects),
                "posted by: {.creator}";
            say .alert;
            say();
        }
        @alerts or say "No new alerts since {DateTime.new: $last-time}";
    }
    else {
        say "Error fetching alerts: " ~ $^e.exception.message
    }

    # OUTPUT:
    # Saved last fetch time to /home/zoffix/.last-p6lert.data
    #
    # ID#5 | 2017-12-28T23:45:28Z | severity: high
    # affects: foos and meows | posted by: Zoffix Znet
    # testing5

    # ID#4 | 2017-12-28T23:42:29Z | severity: critical
    # affects: foos and meows | posted by: Zoffix Znet
    # testing43
```

# DESCRIPTION

Implementation of [alerts.perl6.org](https://alerts.perl6.org) API, as
described on [alerts.perl6.org/api](https://alerts.perl6.org/api)

# TESTING

To run the full test suite, set `ONLINE_TESTING` env var to a true value.
You can also set `WWW_P6LERT_API_URL` env var to the alternate value for
`.api-url` attribute.

# ATTRIBUTES

## `.api-url`

```perl6
    WWW::P6lert.new: :api-url<http://localtesting:10000/api/v1>;
```

**Optional**. `Str` that specifies the API URL to use. **Defaults to:**
`https://alerts.perl6.org/api/v1` and you unless you're testing something
with a local build of the site, you don't ever need to change.

# CONSTRUCTOR

## `.new`


```perl6
    my $alerts := WWW::P6lert.new;

    my $alerts := WWW::P6lert.new: :api-url<http://localtesting:10000/api/v1>;
```

Creates a new `WWW::P6lert` object. Optionally takes `:api-url` named
parameter, providing the value for `.api-url` attribute.

# METHODS

On network error, all methods [`fail`](https://docs.perl6.org/routine/fail)
with `WWW::P6lert::X::Network` error, which does `WWW::P6lert::X` role
and whose `Str` attribute `.error` has explanation for failure.

## `.all`

```perl6
    method all ();
```

Gives all alerts available on the site. Returns a `Seq` where each item
is a `WWW::P6lert::Alert` object representing an alert.

```perl6
    say "All alerts:";
    say "Alert ID#{.id} says {.alert}" for $alerts.all;
```

## `.last`

```perl6
    method last (UInt $n where * < 1_000_000);
```

Gives last `$n` most recent alerts available on the site.
Returns a `Seq` where each item is a `WWW::P6lert::Alert` object representing
an alert.

```perl6
    say "5 most recent alerts:";
    say "Alert ID#{.id} says {.alert}" for $alerts.last: 5;
```

## `.since`

```perl6
    multi method since (Dateish $time);
    multi method since (UInt $time);
```

Gives all alerts available on the site that were posted since `$time`.
Returns a `Seq` where each item is a `WWW::P6lert::Alert` object representing
an alert. If `$time` is given as a `UInt`, it's assumed to mean
[Unix epoch time](https://en.wikipedia.org/wiki/Unix_time).

```perl6
    say "Alerts since yesterday:";
    say "Alert ID#{.id} says {.alert}"
        for $alerts.since: Date.today.earlier: :day;
```

## `.alert`

```perl6
    method alert (UInt $id);
```

Returns `WWW::P6lert::Alert` object representing an alert whose ID is the `$id`.
If no such alert exists, [`fails`](https://docs.perl6.org/routine/fail)
with `WWW::P6lert::X::Network` error, which does `WWW::P6lert::X` role.

```perl6
    $alerts.alert: 42
        andthen "Alert ID#42 says {.alert}".say
        orelse "Couldn't get it";
```

# `WWW::P6lert::Alert` object

Most `WWW::P6lert` methods return `WWW::P6lert::Alert` objects. These objects
cannot be instantiated by the user and only have read-only attributes:

## ATTRIBUTES

### `.id`

`UInt` containing unique ID of the alert.

### `.alert`

`Str` containing alert's text.

### `.time`

`UInt` containing alert's creation time in [Unix epoch
time](https://en.wikipedia.org/wiki/Unix_time)

### `.creator`

`Str` containing alert's creator's name or string `Anonymous` if the alerts site
does not know who created the alert.

### `.affects`

`Str` containing information on what the alert affects. If this information
is absent, contains an empty string.

### `.alert`

`Str` containing alert's severity level, which is one of the values
`info`, `low`, `normal`, `high`, and `critical`.

----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-WWW-P6lert

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-WWW-P6lert/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
