# NAME

Crust::Middleware::Session::Store::DBIish - Implements database storage role for Crust::Middleware::Session

[![Build Status](https://travis-ci.org/adaptiveoptics/Crust-Middleware-Session-Store-DBIish.svg?branch=master)](https://travis-ci.org/adaptiveoptics/Crust-Middleware-Session-Store-DBIish)

# SYNOPSIS

```perl
    use Crust::Builder;
    use Crust::Middleware::Session;
    use Crust::Middleware::Session::Store::DBIish;

    sub app($env) {
        $env<p6sgix.session>.get('username').say if $env<p6sgix.session>.defined;
        $env<p6sgix.session>.set('username', 'ima-username');

        # ...crust-y stuff...
    }

    my $store   = Crust::Middleware::Session::Store::DBIish.new(:dbh($dbh));
    my $builder = Crust::Builder.new;
    
    $builder.add-middleware('Session', store => $store);
    $builder.wrap(&app);
```

# DESCRIPTION
    
Crust::Middleware::Session::Store::DBIish implements a backend storage
role for Crust::Middleware::Session in any database supported by
DBIish.

You must pass in a database handle to `new()`.

Session data is stored serialized in the database table as JSON and is
de-serialized from JSON on get, and made available via the normal
Crust::Middleware::Session methods.

The very fast and compact JSON::Fast is used to serialize and
de-serialize the session data to the database table.

# ATTRIBUTES

## dbh

An active DBIish database handle to the database where session data
will be stored.

## table

Table name that will store session data (defaults to "sessions").

## sessid-column

By default the "id" database column is used for cookie session id
searches and updates. You can change the column name used to identify
session ids with sessid-column in case your 'id' column is used for
something else.

# DATABASE

The database table is called "sessions" by default. This table needs
at least 2 columns, named "id" and "session_data".

The `id` column is the SHA key used as sessions identifiers by
Crust::Middleware::Sessions, and the `session_data` column should
be big enough to hold as much session data as you think you might
need.

The one I just created for sessions was done as follows, and includes
a column of "created" which contains the time that particular session
was created (for later database purging).

    $dbh.do(qq:to/SQL/);
    CREATE TABLE IF NOT EXISTS sessions (
        id TEXT PRIMARY KEY,
        session_data text,
        created timestamp with time zone not null default now()
    )
    SQL

You probably should probably make your "id" column unique, as happens
with Postgresql's PRIMARY KEY attribute.

# AUTHOR

Mark Rushing <mark@orbislumen.net>

# LICENSE

This is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.
