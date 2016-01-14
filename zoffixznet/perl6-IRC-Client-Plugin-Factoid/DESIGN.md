# Design Notes

## Purpose Overview

The plugin provides features of a "factoid bot." Given a keyword—a factoid—it
responds with a pre-defined value for that factoid.

IRC users can add, modify, and delete factoids. Revision history is kept to
allow lower-privileged users to modify the database, without the risk of
permanent loss of data. More-privileged users are allowed to purge factoids
entirely, including the revision history.

The plugin needs to provide the means to view revision history (which can be
lengthy) as well as a rudimentary search feature.

The plugin also needs a means to specify a trigger, to allow the end user to
prevent clashes between the factoid plugin and other functionality of their
client.

## Database

The factoids are to be stored in an SQLite database. The filename of the
database must be changeable by the user.

## Trigger

All commands provided by the plugin must be prefixed with a trigger defined
by the end user with a regex. By default, such trigger won't be specified.

## Responses

The plugin must handle addressed, notice, and private message requests and
respond using the same method.

In addition, the plugin must handle un-addressed channel queries, but this
won't be enabled by default. This will allow a bot to respond to, say,
triggered `!factoid` channel requests or even untriggered messages, such as
`hello`.

## Adding Factoids

Adding a new factoid is done by separating the keyword and the definition
with special word `:is:`. The addition always inserts the factoid into the
database and never updates one. The integer primary key serves as the revision
ID (highest ID on the most current definition of a factoid).

By default, any IRC user with a non-negative privilege level can add new
factoids.

It needs to be evaluated whether there's an issue
with adding a factoid containing multiple `:is:` words and then subsequent
retrieval/deletion of such a factoid.

### Case-sensitivity

Factoid names must be case-insensitive, as it simplifies look up greatly.
However, some factoids may have differnt values depending on their case
(e.g. descriptions of `int` and `Int` Perl 6 types). Thus, it must be
possible to enable case-sensitivity per-factoid. This is to be done
with command `:IS:` instead of regular `:is:`. Factoids added with such a
command must be case-sensitive when doing a look up, deleting, or purging.

## Modifying Factoids

Modification of a factoid is done the same way as
[adding a new one](#adding-factoids), with same default permission levels.

## Deleting Factoids

Deleting a factoid is done by using `^delete FACTOID`, where the carrot
is part of the command, to avoid clashes with defined factoids, and
`FACTOID` is the name of the factoid to delete.

Functionally, deleting a factoid is the same as
[adding a new one](#adding-factoids) with an empty string value and has the same
default user permissions. Thus, deletion is merely a new step in the revision
history. The factoid is still kept in the database.

## Purging Factoids

Purging a factoid is done by using `^purge FACTOID`, where the carrot
is part of the command, to avoid clashes with defined factoids, and
`FACTOID` is the name of the factoid to purge.

Purging completely removes a factoid from the database, along with its
revision history. By default, only users with privilege level of 50 can
purge factoids.

## Fetching Factoids

Factoids are fetched whenever none of the other commands match the user's
request, in which case it's taken as the factoid name to fetch.

When fetching a factoid, the one with the highest ID is designated as the
most current one.

### Factoid Value Exists

Simply respond with the value from the database.

### Emptry String Value

If its value is an empty string, the plugin must respond
with a message that the factoid was deleted and a suggestion to view
revision history.

### Factoid Not Found

If the factoid is not found, the plugin must respond with a message saying so,
which is the default behaviour. The plugin must provide a means for the end
user to change this behaviour and let the plugin return `IRC_NOT_HANDLED`
constant instead, to allow the next plugin in the chain to handle the query
(e.g. using a Google plugin when a factoid isn't found).

#### Level-2 Implementation

---
> A possible future implementation can offer suggestions instead of a plain
'not found' message.

---

## Viewing Revision History

Viewing a revision history of a factoid is done by using
`^history FACTOID`, where the carrot
is part of the command, to avoid clashes with defined factoids, and
`FACTOID` is the name of the factoid whose history to view.

This feature needs to address
[handling of large output](#handling-of-large-output).

## Search

Searching for a factoid is done by using `^search TERM`, where the carrot
is part of the command, to avoid clashes with defined factoids, and
`TERM` is the term to search for.

The term will be considered a substring in either the factoid or its value
and all results will be returned. Deleted factoids need to be excluded from
the results.

This feature needs to address
[handling of large output](#handling-of-large-output).

### Factoid name-only search

Since sometimes the user might have a hint of what a factoid's name is and
doing full search might turn up too many results, the plugin must offer a
`^shortsearch TERM` command that will function exactly as
[full search](#search), except it will search through factoid names only.

## Handling of large output

If the output
is too large, it should be placed into a pastebin and the link to it given
to the user.

---
> **IMPLEMENTATION DETAILS ISSUE:** what is
considered "too large" should really be set somewhere in IRC::Client object.
Also, the pastebinning should likely be done by a separate pastebin plugin. I
think, currently, I'm fine with setting "too large" at 400 chars and simply
sending all output to the user, special-casing in-channel response for super
large outputs with a notice that the user must use a `/notice` or `/msg` to
view the output.

---

## Level-2 Implementation: Help

---
> There should be a way for a user to request a list of available commands
and explanation of how to use them. This is likely should be done with some
sort of a Help plugin, which is not implemented yet.

---

## Level-2 Implementation: Dump All

---
> **Note:** this feature is currently just a brain-storm and not a spec

---

Dumping all factoids is done by using `^dump`, where the carrot
is part of the command, to avoid clashes with defined factoids.

This command will [pastebin](#handling-of-large-output) all the factoids and
their definitions. The command can potentially take an argument to specify
what and how should be pastebinned: for example, the binary SQLite db can be
uploaded somewhere, or revision history can be included in the pastebin.
