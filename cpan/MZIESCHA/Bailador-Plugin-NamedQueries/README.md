NAME
====

DBIx::NamedQueries - a predefined sql framework for Perl6

SYNOPSIS
========

Build a class for yout predefined SQL-Statements

    use Bailador;
    use Bailador::Plugin::NamedQueries;
     
    get '/' => sub {
        template 'index.html', _html_render_fix {
            result  => self.plugins.get('NamedQueries').read: 'user/select'
        }
    }

    baile();

INSTALLATION
============

    > zef install DBIx::NamedQueries

DESCRIPTION
===========

This plugin is a thin wrapper around [DBIx::NamedQueries](DBIx::NamedQueries).

CONFIGURATION
=============

Configuration can be done in your [Bailador](Bailador) config file. This is a minimal example:

    plugins:
      NamedQueries:
        divider: '/'
        namespace: R3Scheduler::Db::Queries
        handle:
          type: DBIish
          driver: SQLite
          database: test.sqlite3

FUNCTIONS
=========

read
----

read
----

write
-----

write
-----

create
------

insert
------

select
------

object
------

Returns the DBIx::NamedQueries object for itself.

dispose
-------

TODO
====

more documentation

SEE ALSO
========

[https://github.com/perl6/DBIish](https://github.com/perl6/DBIish), [https://modules.perl6.org/dist/DBIx::NamedQueries](https://modules.perl6.org/dist/DBIx::NamedQueries)

AUTHOR
======

Mario Zieschang <mziescha [at] cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Mario Zieschang

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

