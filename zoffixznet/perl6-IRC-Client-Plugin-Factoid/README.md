[![Build Status](https://travis-ci.org/zoffixznet/perl6-IRC-Client-Plugin-Factoid.svg)](https://travis-ci.org/zoffixznet/perl6-IRC-Client-Plugin-Factoid)

# NAME

IRC::Client::Plugin::Factoid - factoid bot

# SYNOPSIS

```perl6
    use IRC::Client;
    use IRC::Client::Plugin::Factoid;

    IRC::Client.new(
        :nick<huggable>
        :host<irc.freenode.net>
        :channels<#perl6>
        :plugins( IRC::Client::Plugin::Factoid.new )
    ).run;
```

```irc
<Zoffix> huggable, Int
<huggable> Zoffix, class Int [Integer (arbitrary-precision)]: http://doc.perl6.org/type/type/Int
<Zoffix> huggable, Zoffix :is: awesome!
<huggable> Added Zoffix as awesome!
<Zoffix> huggable, Zoffix
<huggable> Zoffix, awesome!
<Zoffix> huggable, ^delete Zoffix
<huggable> Marked factoid `Zoffix` as deleted
<Zoffix> huggable, ^purge Zoffix
<huggable> Purged factoid `Zoffix` and its 2 edits
```

# EARLY RELEASE

---
***NOTE:*** this is an early release that is currently untested and incomplete.
Database format may change. Not all of the interface is implemented yet.
See [DESIGN docs](DESIGN.md) for complete feature list planned.

---

# DESCRIPTION

This plugin allows to store "factoids": shorts bits of information tagged
with a name and retrieved by asking the plugin for that name. Edit history
is preserved to allow modification access to be given to a wider audience
of users.

The factoids are stored in an SQLite database and you'll need SQLite development
library installed (`sudo apt-get install libsqlite3-dev` on Debian).

# METHODS

## `.new`

Creates and returns a new `IRC::Client::Plugin::Factoid` object.
See [ATTRIBUTES section](#attributes) for valid arguments you can specify.

# ATTRIBUTES

```perl6
    IRC::Client::Plugin::Factoid.new:
        :trigger(/^ '!'/)
        :!say-not-found
        :db-filename<my-factoids.db>;
```

## `trigger`

**Optional.** Takes a `Regex` as a value that specifies the trigger to watch
for in the messages to use plugin features. The `trigger` will be
***stripped*** from the messages, so ensure it does not match any factoid values
**By default** not specified, which causes all messages to be interpreted as
commands or factoid lookup.

## `say-not-found`

**Optional.** Takes a `Bool` as a value that specifies whether the plugin
should respond with 'Factoid not found' message during look ups. If set
to `False`, the plugin will let the message percolate further down the
plugin chain. **Defaults to** `True`.

## `db-filename`

**Optional.** Takes an `Str` that specifies the filename of the SQLite database
file to use. **Defaults to** `factoids.db`.

# IRC COMMANDS

The plugin enables the following IRC commands the IRC Client will respond to.
The responses will be generated when the client is addressed in the channel or
talked to via `/notice` or `/msg`. If [`trigger`](#trigger) is specified,
it must be used for **all** commands.

## Factoid look up

```irc
<Zoffix> huggable, Int
<huggable> Zoffix, class Int [Integer (arbitrary-precision)]: http://doc.perl6.org/type/type/Int
```
Factoid look up is done by simply specifying the name of the factoid to
fetch.

## Adding/Modifying factoids

```irc
<Zoffix> huggable, Zoffix :is: awesome!
<huggable> Added Zoffix as awesome!
```

To add a factoid, separate the name of the factoid from its definition with
keyword `:is:`. Currently, factoid names are case-insensitive.

Modifying a factoid is done the same way.

## Deleting factoids

```irc
<Zoffix> huggable, ^delete Zoffix
<huggable> Marked factoid `Zoffix` as deleted
```

To delete a factoid, use the `^delete` command, followed by the name of the
factoid to delete. Note that this step does not purge the factoid from the
database and all the edit history remains.

## Purging factoids

```irc
<Zoffix> huggable, ^purge Zoffix
<huggable> Purged factoid `Zoffix` and its 2 edits
```

Purging factoids is done with the `^purge` command, followed by the name of
the factoid to purge. Purging is similar to deleting a factoid, except it
completely removes it from the database, including all of the edit history.

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-IRC-Client-Plugin-Factoid

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-IRC-Client-Plugin-Factoid/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
