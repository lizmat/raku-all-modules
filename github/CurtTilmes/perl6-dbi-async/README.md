NAME
====

DBI::Async - Tiny async wrapper around DBIish

SYNOPSIS
========

    use DBI::Async;

    # Pass any DBIish.connect() options
    # connections defaults to 5

    my $db = DBI::Async.new('Pg', connections => 5);

    # Make blocking requests:

    my $result = $db.query("select version()");
    say $result.row[0];
    $result.finish;

    # Use array() instead of row() to auto-finish the results:

    say $db.query("select version()").array[0];  # array() auto-finishes

    # Use :async to immediately get a Promise:

    my $promise = $db.query("select version()", :async);

    await $promise.then(-> $p
    {
        say $p.result.array[0];
    });

    # Or even start a bunch of background queries in parallel,
    # then check the results

    await do for 1..10
    {
        start {
            say "starting $_";
            say "Done #", $db.query("select pg_sleep(1)::text, ?::int as val",
                                    $_).array[1];
        }
    }

    # same

    await do for 1..10
    {
        say "starting $_";
        $db.query("select pg_sleep(1)::text, ?::int as val", $_, :async).then(
                  -> $p { say "Done #", $p.result.array[1] });
    }

    $db.dispose; # Drop all queued handles

DESCRIPTION
===========

`DBI::Async` is an experimental wrapper around DBIish that does all the heavy lifting. It manages a pool of connections and as queries are issued, it queues them and allocates them to a connection, gets the results and returns them asynchronously. You can issue queries from multiple threads without worrying about managing connections. It also wraps some of the mechanics of dealing with results.

Passes all arguments to DBI::Async.new() through to DBIish.connect() except connections.

    my $db = DBI::Async.new('Pg', connections => 5);

Connections constrains the object from creating more than $connections database handles.

Each call to query() queues the database query for the query scheduler.

To process each query, it will use a free database handle from the handle pool. It will create up to $connections new handles. If no handles are available, it wait until another query completes and returns a handle.

query() returns a DBI::Async::Results object. It supports the basic methods from DBIish statement handles:

    .column-names()  # Array of column names
    .column-types()  # Array of column types
    .rows()          # Count of rows returns
    .row()           # Get a single row, call repeatedly to get all
    .allrows()       # Lazy list of all rows suitable for iteration

It has a special version of .finish() that returns the database handle to the pool to be reused by other queries. If you access your results with the methods above, you must explicitly call .finish() to return the handle. (Otherwise they will leak and not be available for use until the garbage collector gets around to reaping them.)

    my $result = $db.query("select version()");
    say $result.row[0];
    $result.finish;

To make this a little easier for common cases, the Results object has some extra methods that automatically grab the results and finish() for you.

    .array()     # Return a single row as an array
    .hash()      # Return a single row as a hash
    .arrays()    # Eagerly get all rows and return as an array of arrays
    .flatarray() # Flatten all elements of all rows into a single array
    .hashes()    # Eagerly get all rows and return as an array of hashes

If and only if you use those methods to get results, the finish() will be automatically called.

    say $db.query("select version()").array[0];

If you do want to use, e.g. .allrows() to process your results, the LEAVE phaser or corresponding 'will leave' trait, can help assure that the .finish() gets called, even if the processing code throws an exception.

These are identical:

    {
        my $res = $db.query(blah blah);
        LEAVE $res.finish;
        while $res.allrows -> $r {
           ...do something...
        }
    }

or

    {
        my $res will leave { .finish } = $db.query(blah blah);
        while $res.allrows -> $r {
           ...do something...
        }
    }

PROMISES
--------

If you include the :async adverb in a call to query(), instead of waiting for the result, a Promise will be returned that will be kept when the results of the database query are available.

    my $promise = $db.query("select version()", :async);

    await $promise.then(-> $p
    {
        say $p.result.array[0];
    });

You can have more outstanding queries than you have database connections available. The additional queries will queue up and get executed once previous queries complete and their results are processed.

    my $db = DBI::Async.new('Pg', connections => 10);

    await do for 1..100
    {
        say "starting $_";
        $db.query("select pg_sleep(1)::text, ?::int as val", $_, :async).then(
                  -> $p { say "Done #", $p.result.array[1] });
    }

This allocates 10 database handles, then processes the 100 queries in parallel, 10 at a time. Since the results are processed with array(), the handles are returned to the pool immediately when the result is returned.

Make sure you don't take up too many waiting threads without leaving enough open threads to get work done and return handles for the rest of the waiting queries. You may be able to get around this by increasing $RAKUDO_MAX_THREADS. Also see: https://github.com/rakudo/rakudo/pull/1004

RETRIES
-------

DBI::Async aggressively tries to open a database connection. If the connection can't be made immediately, it will sleep a while and try again, 1 second, then 2 seconds, then 3 seconds... up to 60 seconds, finally trying to open the database connection every 60 seconds. This happens both on inital database handle creation, or on subsequent reuse of an existing handle where the connection is dropped.

COPYRIGHT
=========

Copyright © 2017 United States Government as represented by the Administrator of the National Aeronautics and Space Administration. No copyright is claimed in the United States under Title 17, U.S.Code. All Other Rights Reserved.
