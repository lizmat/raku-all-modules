[![Build Status](https://travis-ci.org/mziescha/perl6-DBIx-NamedQueries.svg?branch=master)](https://travis-ci.org/mziescha/perl6-DBIx-NamedQueries)

NAME
====

DBIx::NamedQueries - a predefined sql framework for Perl6

SYNOPSIS
========

Build a class for yout predefined SQL-Statements

    use DBIx::NamedQueries;

    class Queries::Write::Test does DBIx::NamedQueries::Write {
        
        method alter ( %params ) { }
        
        method create ( %params ) {
            return {
                statement => qq~
                    CREATE TABLE users (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        name varchar(4) UNIQUE,
                        description varchar(30),
                        quantity int,
                        price numeric(5,2)
                    );
                ~
            };
        }
        
        method insert ( %params ) {
            return {
                fields => [ 'name', 'description', 'quantity', 'price', ],
                statement => qq~INSERT INTO users (name, description, quantity, price)
                      VALUES ( ?, ?, ?, ? )~
            };
        }
        
        method update ( %params ) { }
    }

Create a namedquery instance

    my $namedqueries = DBIx::NamedQueries.new(
        namespace => 'Queries',
        handle    => {
            type     => 'DBIish',
            driver   => 'SQLite',
            database => 'test.sqlite3',
        },
    );

And now the namedquery instance is writing the table users with the predefined SQL-Statement

    $namedqueries.write( 'test/create' );

INSTALLATION
============

    > zef install DBIx::NamedQueries

DESCRIPTION
===========

FAQ
===

Motivation
----------

This is my first perl6 module on cpan. I needed a project to learn the programming language. And I hope it helps someone to handle a huge amount SQL-Statements.

TODO
====

documentation

SEE ALSO
========

[https://github.com/perl6/DBIish](https://github.com/perl6/DBIish)

AUTHOR
======

Mario Zieschang <mziescha [at] cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Mario Zieschang

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

