[![Build Status](https://travis-ci.org/zoffixznet/perl6-RT-REST-Client.svg)](https://travis-ci.org/zoffixznet/perl6-RT-REST-Client)

# NAME

RT::REST::Client - Use Request Tracker's (RT) REST client interface

# TABLE OF CONTENTS
- [NAME](#name)
- [SYNOPSIS](#synopsis)
- [EARLY RELEASE](#early-release)
- [LOGIN CREDENTIALS](#login-credentials)
- [METHODS](#methods)
    - [`.new`](#new)
        - [`:user`](#user)
        - [`:pass`](#pass)
        - [`:rt-url`](#rt-url)
    - [`.search`](#search)
        - [`:after`](#after)
        - [`:before`](#before)
        - [`:queue`](#queue)
        - [`:status`](#status)
        - [`:not-status`](#not-status)
- [`RT::REST::Client::Ticket` OBJECT](#rtrestclientticket-object)
    - [`.id`](#id)
    - [`.tags`](#tags)
    - [`.subject`](#subject)
    - [`.url`](#url)
- [REPOSITORY](#repository)
- [BUGS](#bugs)
- [AUTHOR](#author)
- [LICENSE](#license)

# SYNOPSIS

```perl6

my RT::REST::Client $rt .= new: :user<rt@example.com> :pass<secr3t>;
printf "#%s %s %s\n\t%s\n\n",
        .id, .tags.join(' '), .subject, .url
    for $rt.search: after => Date.today.earlier: :week;
```

# EARLY RELEASE

Currently only search feature is supported. More features will be added as
needed, upon request.

# LOGIN CREDENTIALS

You need to go to user preferences and set up your CLI password for your
credentials to work via REST API. For Perl 6's RT, go to
[https://rt.perl.org/User/Prefs.html](https://rt.perl.org/User/Prefs.html)
and the CLI Password section should be on the right side of the page.

# METHODS

## `.new`

```perl6
    my RT::REST::Client $rt .= new:
        :user<rt@example.com>
        :pass<secr3t>
        :rt-url<https://rt.example.com/REST/1.0> # optional
    ;
```

Creates a new `RT::REST::Client` object. Takes the following named arguments:

### `:user`

**Mandatory.** Your RT username

### `:pass`

**Mandatory.** Your RT password. Note that your regular web login likely won't
work. You need to set up the CLI password. See [LOGIN CREDENTIALs
section](#login-credentials) for details.

### `:rt-url`

**Optional.** The URL of the REST API for your RT service.
**Defaults to:** `https://rt.perl.org/REST/1.0`

## `.search`

```perl6
    my @tickets = $rt.search; # all open and new tickets

    # detailed search
    my @tickets = $rt.search:
        :after( Date.today.earlier: :week  )
        :before(Date.today.earlier: :2weeks)
        :queue<perl6>
        :status<open new>
        :not-status<stalled>
    ;
```

Performs a search for tickets and returns a possibly-empty list of
[`RT::REST::Client::Ticket` objects](#rtrestclientticket-object). Returns a `Failure` on network errors
or if RT's response was not understood (e.g. incorrect login credentials).
Takes the following named arguments:

### `:after`

**Optional.** Takes a `Dateish` object. Instructs to search for tickets
that were created *on* or after this date. **By default** is not specified.

### `:before`

**Optional.** Takes a `Dateish` object. Instructs to search for tickets
that were created before this date (date itself is not included).
**By default** is not specified.

### `:queue`

**Optional.** Takes a `Str` with the ticket queue to search.
**Defaults to** `perl6`

### `:status`

**Optional.** Takes a list of `Str` statuses. A ticket will be included
if it matches *any* of the statuses. **By default** is not specified,
but if `:not-status` is also not specified, the search will operate as if
`:not-status` was set to `<resolved rejected>`

### `:not-status`

**Optional.** Takes a list of `Str` statuses. A ticket will be excluded
if it matches *any* of the statuses. **By default** is not specified,
but if `:status` is also not specified, the search will operate as if
`:not-status` was set to `<resolved rejected>`


# `RT::REST::Client::Ticket` OBJECT

The `.search` method returns a list of `RT::REST::Client::Ticket` objects,
which have the following attributes:

```perl6
    my class RT::REST::Client::Ticket {
        has $.id;
        has $.tags;
        has $.subject;
        has $.url;
    }
```

## `.id`

The ID of the ticket.

## `.tags`

A possibly-empty list of ticket's tags. Currently, these are obtained
from the braketed markers (e.g. `[FOO]`) at the start of the ticket's subject
line. The brakets are retained as part of the tag.

## `.subject`

The subject line of the ticket. If any tags are present at the start, they will
be stripped.

## `.url`

The URL of the ticket.

----

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-RT-REST-Client

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-RT-REST-Client/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
