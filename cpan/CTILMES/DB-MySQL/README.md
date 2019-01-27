DB::MySQL - MySQL access for Perl 6
===================================

This is a reimplementation of Perl 6 bindings for MySQL.

Basic usage
-----------

```perl6
use DB::MySQL;
my $mysql = DB::MySQL.new();  # You can pass in various options
```

Execute a query, and get a single value:
```perl6
say $mysql.execute('select 42').value;
# 42
```

Create a table:
```perl6
$mysql.execute('create table foo (x int, y varchar(80))');
```

Insert some values using placeholders:
```perl6
$mysql.query('insert into foo (x,y) values (?,?)', 1, 'this');
```

Execute a query returning a row as an array or hash;
```perl6
say $mysql.query('select * from foo where x = ?', 1).array;
say $mysql.query('select * from foo where x = ?', 1).hash;
```

Execute a query returning a bunch of rows as arrays or hashes:

```perl6
.say for $mysql.query('select * from foo').arrays;
.say for $mysql.query('select * from foo').hashes;
```

`.query()` caches a prepared statement, and can have placeholders and
arguments - `.execute()` does not prepare/cache and can't have
placeholders.  Both can return results.

Installation
------------

This module relies on `libmysqlclient.so`.  For Ubuntu, I install this
with:

```
sudo apt install libmysqlclient-dev
```

I worked with version 5.7 of the API.  It may or may not work with
other versions.  You can see the client version with:

```
perl6 -MDB::MySQL::Native -e 'say mysql_get_client_info'
```

There are likely 64-bit Linux dependencies in the code.  Patches
welcome if someone wants to make it on other OSes.

Connection Information
----------------------

There are many options that can be specified to `DB::MySQL.new()`:

* `:host` - defaults to `localhost`

* `:port` - defaults to `3306`

* `:user`

* `:password`

* `:socket`

* `:database` - optional, sets current database

* `:connect-timeout` - timeout in seconds for a connect attempt.

* `:read-timeout` - timeout in seconds for each attempt to read
  from the servers.

* `:write-timeout` - timeout in seconds for each attempt to write to
  the server.

* `:default-file` - Read options from the named file instead of
  `my.cnf`.

* `:group` - defaults to 'client'.  Reads options from the specified
  group in the `.my.cnf` file. Undefine this to ignore defaults file.

The easiest way to connect is to put your options in `.my.cnf`.

DB::MySQL::Connection
----------------------

The main **DB::MySQL** object acts as a factory for connections,
maintaining a cache of connections already created.  A new connection
can be requested with the `.db` method, but often this isn't needed.
When you are finished with a connection, you can explicitly return it
to the cache with `.finish`.

You can call `.query()` or `.execute()` on the main **DB::SQLite**
object, but all they really do is allocate a
**DB::SQLite::Connection** (either from the cache, or create a new
one) and call those methods on it, then return the connection to the
cache.

These are equivalent:

```perl6
.say for $mysql.query('select * from foo').arrays;
```

```perl6
my $db = $mysql.db;
.say for $mysql.query('select * from foo').arrays;
$db.finish;
```

The connection object also has some extra methods for separately
preparing and executing the query:

```perl6
my $db = $mysql.db;
my $sth = $db.prepare('insert into foo (x,y) values (?,?)');
$sth.execute(1, 'this');
$sth.execute(2, 'that');
$db.finish;
```

You can also call `.finish()` on the statement:

```perl6
my $sth = $mysql.db.prepare('insert into foo (x,y) values (?,?)');
$sth.execute(1, 'this');
$sth.execute(2, 'that');
$sth.finish;
```

The statement will finish the associated connection, returning it to
the cache.  Yet another way to do it is to pass `:finish` in to the
execute.

```perl6
my $sth = $mysql.db.prepare('insert into foo (x,y) values (?,?)');
$sth.execute(1, 'this');
$sth.execute(2, 'that', :finish);
```

And finally, a cool Perl 6ish way is the `will` trait to install a
Phaser directly on the variable:

```perl6
{
    my $sth will leave { .finish } = $mysql.db.prepare('insert into foo (x,y) values (?,?)');
    $sth.execute(1, 'this');
    $sth.execute(2, 'that');
}
```

Calling `.prepare()` on the **DB::MySQL::Connection** prepares and
returns a **DB::MySQL::Statement** that can then be `.execute()`ed.
The prepared statement is also retained in a cache with the
connection.  If the same statement is prepared again on the same
connection, the cached object will be returned instead of
re-preparing.  If you don't want it to be cached, you can pass in the
`:nocache` option.

```perl6
my $sth = $mysql.db.prepare('insert into foo (x,y) values (?,?)', :nocache);
$sth.execute(1, 'this');
$sth.execute(2, 'that', :finish);
```

You must still take care to call `.finish()` to return the connection
to the connection cache so it will get reused.  (Or take care NOT to
call `.finish()` if you don't want the connection to be reused,
possibly in another thread.)

For the main object, or the connection object, `.execute()` is used
instead of `.query()` if you don't need placeholders/arguments.

Transactions
------------

The database connection object can also manage transactions with the
`.begin`, `.commit`, and `.rollback` methods:

```perl6
my $db = $mysql.db;
my $sth = $db.prepare('insert into foo (x,y) values (?,?)');
$db.begin;
$sth.execute(1, 'this');
$sth.execute(2, 'that');
$db.commit;
$db.finish;
```
The `begin`/`commit` ensure that the statements between them happen
atomically, either all or none.

Transactions can also dramatically improve performance for some
actions, such as performing thousands of inserts/deletes/updates since
the indexes for the affected table can be updated in bulk once for the
entire transaction.

If you `.finish` the database prior to a `.commit`, an uncommitted
transaction will automatically be rolled back.

As a convenience, `.commit` also returns the database object, so you
can just `$db.commit.finish`.

Results
-------

Calling `.query()` on a **DB::MySQL** or **DB::MySQL::Connection**,
or calling `.execute()` on a **DB::SQLite::Statement** with an SQL
SELECT or something that returns data, a `DB::SQLite::Result` object
will be returned.

The query results can be consumed from that object with the following
methods:

* `.value` - a single scalar result
* `.array` - a single array of results from one row
* `.hash` - a single hash of results from one row
* `.arrays` - a sequence of arrays of results from all rows
* `.hashes` - a sequence of hashes of results from all rows

If the query isn't a select or otherwise doesn't return data, such as
an INSERT, UPDATE, or DELETE, it will return the number of rows
affected.

By default, the entire result of the query is retrieved immediately
from the server to the client.  You can pass in the `:nostore` option
to `.query` or `.execute` to avoid this behavior.  It will then
retrieve the results from the server as you consume them on the
client.  This will hold up server resources while you retrieve the
results, so exercise care with this.

Exceptions
----------

All database errors, including broken SQL queries, are thrown as exceptions.

Acknowledgements
----------------

Inspiration taken from the existing Perl6
[DBIish](https://github.com/perl6/DBIish) module as well as the Perl 5
[Mojo::Pg](http://mojolicious.org/perldoc/Mojo/Pg) from the
Mojolicious project.

License
-------

Portions thanks to DBIish:

Copyright © 2009-2016, the DBIish contributors All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
