use v6;

use ModelDB::Collection;
use ModelDB::Column;
use ModelDB::Model;
use ModelDB::RelationshipSetup;
use ModelDB::Schema;
use ModelDB::Table;
use ModelDB::TableBuilder;

module ModelDB:ver<0.0.3>:auth<github:zostay> {}

=begin pod

=head1 NAME

ModelDB - an MVP ORM

=head1 SYNOPSIS

    use DBIish;
    use ModelDB;

    module Model {
        use ModelDB::ModelBuilder;

        model Person {
            has Int $.person-id is column is primary;
            has Str $.name is column is rw
            has Int $.age is column is rw;
            has Str $.favorite-color is column is rw;
        }

        model Pet {
            has Str $.pet-id is column is primary;
            has Str $.name is column is rw;
            has Str $.animal is column is rw;
        }
    }

    class Schema is ModelDB::Schema {
        use ModelDB::SchemaBuilder;

        has ModelDB::Table[Person] $.persons is table;
        has ModelDB::Table[Pet] $.pets is table;
    }

    my $dbh = DBIish.connect('SQLite', :database<db.sqlite3>);
    my $schema = Schema.new(:$dbh);

    my $person = $schema.persons.create(%(
        name           => 'Steve',
        age            => 9,
        favorite-color => 'cyan',
    ));

    $person.name           = 'Alex';
    $person.age            = 4;
    $person.favorite-color = 'green';

    $schema.persons.update($person);

    my $by-id = $schema.pets.find(pet-id(1));
    my @cats = $schema.pets.search(:animal<cat>).all;

=head1 DESCRIPTION

This is a minimalist object relational mapping tool. It helps with mapping your database objects into Perl from an RDBMS. I am experimenting with this API to see what I can learn about RDBMS patterns, problems, and specific issues as related to Perl 6.

As such, this is highly experimental and I make no promises as regards the API. Though, I do use it in some production-ish code, so I don't want to change too much too fast.

My intent, though, is to use what I learn here to build a different library in a different namespace that does what I really want based on what I learn here.

My goals include:

=over

=defn Declarative
I provide a DSL for declaring models and schemas because DSLs make the data structures easy to grok. These should, insofar as I am able, keep to standard Perl 6 syntax.

=defn Inversion
I believe that inversion of control and dependency injection patterns are the best way to go, especially as regards ORMs. Therefore, a major goal is to make it so that each object focuses on a single job and can do that job independent of the others. High level glue code then puts the pieces together without the pieces below being involved, insofar as that is feasible.

=defn Query Building
I have some ideas for query building I want to try out, building complex queries in a concise, Perlish way, but without all the esoterical knowledge that something like SQL::Abstract for Perl 5 required.

=defn Perlish
This will make heavy use of traits, roles, typing, etc.

=defn Original
I am trying to build this from first principles without explicitly relying on the details of other solutions.

=back

Performance and multiple RDBMS support are anti-goals. This will likely only support MySQL (and forks) and SQLite because that's what I care about. I do not plan to make performance improvements unless required and I especially do not intend to add any optimizations that harm code readability of even the internals unless required.

=end pod
