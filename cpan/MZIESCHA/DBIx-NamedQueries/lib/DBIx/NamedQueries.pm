use v6.c;

use DBIx::NamedQueries::Handles;

role DBIx::NamedQueries::Read {
    method find(   %params ) { ... }
    method list(   %params ) { ... }
    method select( %params ) { ... }
}

role DBIx::NamedQueries::Write{
    method alter(  %params ) { ... }
    method create( %params ) { ... }
    method insert( %params ) { ... }
    method update( %params ) { ... }
}

class DBIx::NamedQueries:ver<0.0.1>:auth<cpan:MZIESCHA> { 

    has Str   $.divider = '/';
    has Str   $.namespace;
    has Hash  $.handle;
    has DBIx::NamedQueries::Handles $!handles = DBIx::NamedQueries::Handles.new();

    method !object_from_string(Str:D $s_package){
        require ::($s_package);
        return ::($s_package).new;
    }

    method !query_from_string(Str:D $context, Hash:D $hr_params){
        my @splitted_context = split $!divider, $context;
        my $s_sub = pop @splitted_context;
        my $obj_query = self!object_from_string(
            $.namespace ~ '::' ~ join '::', map { $_.tc }, @splitted_context
        );
        return $obj_query."$s_sub"($hr_params);
    }
    
    method !param_filler( Hash:D $given_params, Array:D $fields) {
        return [] if !$given_params.elems;
        return map { %($given_params){$_<name>} }, @($fields) ;
    }

    method !handle_rw () {
        my $handle_rw = $!handles.read_write();
        return $handle_rw if $handle_rw;
        $!handles.add_read_write($.handle<type>, $.handle<driver>, $.handle<database> );
        return $!handles.read_write();
    }

    method !handle_ro () {
        my $handle_ro = $!handles.maybe_read_only();
        return $handle_ro if $handle_ro;
        $!handles.add_read_only($.handle<type>, $.handle<driver>, $.handle<database> );
        return $!handles.maybe_read_only();
    }

    multi method read(Str:D $context){ return self.read($context, {}); }
    multi method read(Str:D $context, Hash:D $params){
        my %from_string = self!query_from_string('Read'~ $.divider ~ $context, $params);
        my $sth    = self!handle_ro.prepare( %from_string.<statement> );
        %from_string<fields>:exists ?? $sth.execute( self!param_filler($params, @(%from_string<fields>)) ) !! $sth.execute();
        return $sth.allrows(:array-of-hash);
    }

    multi method write(Str:D $context){ return self.write($context, {}); }
    multi method write(Str:D $context, Hash:D $params){
        my %from_string = self!query_from_string('Write'~ $.divider ~ $context, $params);
        my $sth = self!handle_rw.prepare(%from_string.<statement>);

        if %from_string<fields>:exists {
            my @fields = @(%from_string<fields>);
            return $sth.execute( map { %($params){$_} }, @fields );
        }
        return $sth.execute();
    }

    method find (Str:D $context, Hash:D $params) {
        return self.read: $context ~ self.divider ~ 'find', $params;
    }

    method list (Str:D $context, Hash:D $params) {
        return self.read: $context ~ self.divider ~ 'list', $params;
    }

    method select (Str:D $context, Hash:D $params) {
        return self.read: $context ~ self.divider ~ 'select', $params;
    }

    method alter (Str:D $context, Hash:D $params) {
        return self.write: $context ~ self.divider ~ 'alter', $params;
    }

    method create (Str:D $context) {
        return self.write: $context ~ self.divider ~ 'create';
    }

    method insert (Str:D $context, Hash:D $params) {
        return self.write: $context ~ self.divider ~ 'insert', $params;
    }

    method update (Str:D $context, Hash:D $params) {
        return self.write: $context ~ self.divider ~ 'update', $params;
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