DB - Base roles for DB::* family of SQL Database Access Modules
===============================================================

[![Build Status](https://travis-ci.org/CurtTilmes/perl6-db.svg)](https://travis-ci.org/CurtTilmes/perl6-db)


This module abstracts out some shared functionality from a set of
concrete modules for performing database access.

You can't actually do anything directly with these.  The documentation
here will only be useful if you want to understand the internals of
the __DB__ modules, or implement your own similar __DB::*__ module.

DB
--
DB holds a cache of database connections.

`.connect(--> DB::Connection)` - virtual, create a new connection

`.db(--> DB::Connection)` - Returns a cached connection

`.cache(DB::Connection:D $db)` - Returns a connection to the cache

`.query()` - Allocates a connection, calls `.query`, then returns
the connection.

`.execute()` - Allocates a connection, calls `.execute`, then
returns the connection.

`.finish()` - For each cached connection, call `.DESTROY`

DB::Connection
--------------

A single active database connection.  It also implements functionality
for a statement cache per connection, so you don't have to remember
which statement was prepared, just call it again.

`.ping(--> Bool)` - test if a connection is still active/viable, to be
overridden if possible.

`.free()` - free the connection, don't make a `DESTROY()`, make this
instead, to be overridden.

`.clear-cache()` - Call `.DESTROY()` for each cached `Statement`.

`.finish()` - Return connection to the main object's cache.

`.prepare-nocache(Str:D $query --> DB::Statement)` - virtual, prepare
the query as a statement.

`.prepare(Str:D $query --> DB::Statement)` - Return a cached
statement, or call `.prepare-nocache`.

`.execute(Str:D $command, Bool :$finish, |args)` - virtual method to
execute a command.  The `$finish` argument says to call `.finish` when
the `execute` is finished.

`.query(Str:D $query, Bool :$finish, |args)` - prepare, then execute
the query

`.begin`, `.commit`, `.rollback` - shortcuts

`.DESTROY()` - `.clear-cache` and `.free`

DB::Statement
-------------

A prepared statement, ready to execute.

`.free()` - Free all resources

`.execute()` - virtual method

`.finish()` - Call the `.finish` on the owning **Connection**

`.DESTROY()` - Just call `.free`

DB::Result
----------

This gets returned with results of a query.  It holds the `Statement`,
and relays the finish back up to the `Statement` to the `Database`.

`.free()` - Free any resources, to be overridden if needed

`.finish()` - call `.free`, then call `.finish` on the `Statement`
that returned these results.

`.row()` - virtual, return the next row of results

`.names()` - virtual, return the string labels for the columns in the
results, used to construct `Hash`es.

`.keys()` - Cache for `.names` so we only call it once.

`.value`, `.array`, `.hash`, `.arrays`, `.hashes` - Return results,
then `.finish`

`.DESTROY()` - just call `.free`

Acknowledgements
----------------

Inspiration taken from the existing Perl6
[DBIish](https://github.com/perl6/DBIish) module as well as the Perl 5
[Mojo::Pg](http://mojolicious.org/perldoc/Mojo/Pg) from the
Mojolicious project.
