use v6.c;

use Bailador::Plugins;

use DBIx::NamedQueries;

class Bailador::Plugin::NamedQueries:ver<0.001000>:auth<cpan:MZIESCHA> is Bailador::Plugin {

    has DBIx::NamedQueries $!named_queries;
    
    method !init () {
        $!named_queries = DBIx::NamedQueries.new(
            divider   => %.config{'divider'},
            namespace => %.config{'namespace'},
            handle    => %.config{'handle'},
        );
    }

    multi method read (Str:D $context) {
        self!init unless $!named_queries;
        return $!named_queries.read: $context;
    }

    multi method read (Str:D $context, Hash:D $params) {
        self!init unless $!named_queries;
        return $!named_queries.read: $context, $params;
    }

    multi method write (Str:D $context) {
        self!init unless $!named_queries;
        return $!named_queries.write: $context;
    }

    multi method write (Str:D $context, Hash:D $params) {
        self!init unless $!named_queries;
        return $!named_queries.write: $context, $params;
    }

    method create (Str:D $context) {
        self!init unless $!named_queries;
        return $!named_queries.create: $context;
    }

    method insert (Str:D $context, Hash:D $params) {
        self!init unless $!named_queries;
        return $!named_queries.insert: $context, $params;
    }

    method select (Str:D $context, Hash:D $params) {
        self!init unless $!named_queries;
        return $!named_queries.select: $context, $params;
    }

    method object() {
        self!init unless $!named_queries;
        return $!named_queries;
    }

    method dispose () {
        return unless $!named_queries;
        $!named_queries.dispose 
    }
}

=begin pod

=head1 NAME

DBIx::NamedQueries - a predefined sql framework for Perl6

=head1 SYNOPSIS

Build a class for yout predefined SQL-Statements

    use Bailador;
    use Bailador::Plugin::NamedQueries;
 
    get '/' => sub {
        template 'index.html', _html_render_fix {
            result  => self.plugins.get('NamedQueries').read: 'user/select'
        }
    }

    baile();

=head1 INSTALLATION

  > zef install DBIx::NamedQueries
 
=head1 DESCRIPTION

This plugin is a thin wrapper around L<DBIx::NamedQueries>.
 
=head1 CONFIGURATION
 
Configuration can be done in your L<Bailador> config file.
This is a minimal example:
 
    plugins:
      NamedQueries:
        divider: '/'
        namespace: R3Scheduler::Db::Queries
        handle:
          type: DBIish
          driver: SQLite
          database: test.sqlite3
 
=head1 FUNCTIONS

=head2 read

=head2 read

=head2 write

=head2 write

=head2 create

=head2 insert

=head2 select

=head2 object

Returns the DBIx::NamedQueries object for itself.

=head2 dispose

=head1 TODO

more documentation

=head1 SEE ALSO

L<<https://github.com/perl6/DBIish>>, L<<https://modules.perl6.org/dist/DBIx::NamedQueries>>

=head1 AUTHOR

Mario Zieschang <mziescha [at] cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Mario Zieschang

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
