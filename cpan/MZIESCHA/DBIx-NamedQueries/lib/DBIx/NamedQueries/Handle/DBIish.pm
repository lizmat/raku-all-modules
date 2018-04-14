use v6.c;

use DBIish;
use DBIx::NamedQueries::Handles;

class DBIx::NamedQueries::Handle::DBIish:ver<0.0.1> does DBIx::NamedQueries::Handle {

    multi method connect( Str:D $driver, Str:D $database ) {
        return DBIish.connect( $driver, :database( $database ) );
    }
}

=begin pod

=head1 NAME

DBIx::NamedQueries - a predefined sql framework for Perl6

=head1 SYNOPSIS

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

And now the namedquery instance is writing the table users with the predefined
SQL-Statement

    $namedqueries.write( 'test/create' );

=head1 INSTALLATION

  > zef install DBIx::NamedQueries

=head1 DESCRIPTION

=head1 FAQ

=head2 Motivation

This is my first perl6 module on cpan. I needed a project to learn the programming language.
And I hope it helps someone to handle a huge amount SQL-Statements.

=head1 TODO

documentation

=head1 SEE ALSO

L<<https://github.com/perl6/DBIish>>

=head1 AUTHOR

Mario Zieschang <mziescha [at] cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Mario Zieschang

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod