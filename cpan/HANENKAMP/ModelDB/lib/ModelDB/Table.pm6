use v6;

use ModelDB::Collection;
use ModelDB::Schema;

class ModelDB::Collection::Table { ... }

=begin pod

=head1 NAME

ModelDB::Table - load, save, and find model data

=head1 SYNOPSIS

    use ModelDB;

    module Model {
        use ModelDB::ModelBuilder;
        model Animal {
            has Int $.animal-id is column is primary;
            has Str $.name is column is rw;
        }
    }

    my ModelDB::Schema $schema .= new(...);
    my ModelDB::Table[Model::Animal] $animals .= new(
        :$schema, :table<animals>
    );

    my $cow = $animals.create(%(:name<Cow>));
    my $pig = $animals.create(%(:name<Pig>));

    my $sheep = $animals.find(:animal-id(4));

    $pig.name = 'Zombie Pigman';
    $animals.update($pig);

=head1 DESCRIPTION

A table provides the operations necessary for loading, searching, saving, and otherwise working with a model object in a concrete way involving a backing store.

The L<#SYNOPSIS> demonstrates how to create table objects directly. However, you will most likely want to do this indirectly through the L<ModelDB::SchemaBuilder>.

=head1 METHODS

=head2 method schema

    has ModelDB::Schema $.schema is required

This is the schema to use for manipulating data.

=head2 method table

    has Str $.table is required

This is the name of the RDBMS table to use.

=head2 method model

    method model(--> ::Model)

This is the model class.

=head2 method escaped-table

    method escaped-table(--> Str)

TODO This does not belong here.

Provides a SQL escaped name for the table.

=head2 method escaped-columns

    multi method escaped-columns(--> Str)
    multi method escaped-columns(@names --> Str)

TODO This does not belong here.

Provides SQL escaped names for columns.

=head2 method select-columns

    method select-columns(%columns --> Seq)

TODO This does not belong here.

Generates a data structure for selecting columns.

=head2 method process-where

    method process-where(%where --> Str)

TODO This is primitive.

Generates a where clause.

=head2 method find

    multi method find(%keys --> ::Model)

Returns the model object with the given primary key or returns C<Nil>.

=head2 method create

    method create(%values, Str :$onconflict)

Creates a model object and returns it.

=head2 method update

    method update(::Model $row)

Given a model object, updates the database to match.

=head2 method delete

    method delete(:%where)

Deletes objects matching the given where clause.

=head2 method search

    method search(*%search --> ModelDB::Collection)

Returns a collection of objects matching the given where clause.

=end pod

role ModelDB::Table[::Model] {
    has ModelDB::Schema $.schema is required;
    has Str $.table is required;

    method model() { Model }

    my sub sql-escape(Str:D $name) returns Str:D {
        $name.trans(['`'] => ['``']);
    }

    my sub sql-quote(Str:D $name) returns Str:D {
        '`' ~ $name ~ '`'
    }

    my &sql-quote-escape = &sql-quote o &sql-escape;

    has $!escaped-table;
    method escaped-table() returns Str {
        $!escaped-table //= sql-escape($!table);
        $!escaped-table
    }

    has @!escaped-columns;
    method !init-escaped-columns() {
        @!escaped-columns = $.model.^column-names.map({ $_ => sql-escape($_) })
            if @!escaped-columns.elems != $.model.^columns.elems;
    }
    multi method escaped-columns() {
        self!init-escaped-columns();
        @!escaped-columns.map({ .value });
    }

    multi method escaped-columns(@names) {
        my $name-matcher = any(|@names);
        self!init-escaped-columns();
        @!escaped-columns.grep({ .key ~~ $name-matcher }).map({ .value });
    }

    multi method escaped-columns(@names, Str :$join!) {
        self.escaped-columns(@names).map(&sql-quote).join($join);
    }

    multi method escaped-columns(Str :$join!) returns Str {
        $.escaped-columns.map(&sql-quote).join($join);
    }

    method select-columns($selector) {
        gather for $.model.^column-names.kv -> $i, $c {
            take self.escaped-columns[$i] if $c ~~ $selector;
        }
    }

    method process-where(%where) {
        return ('',) unless %where;

        my @and-clauses;
        my @bindings;
        for %where.kv -> $column, $value {
            my $escaped = sql-quote-escape($column);
            push @and-clauses, "$escaped = ?";
            push @bindings, $value;
        }

        "WHERE " ~ @and-clauses.join(' AND '), |@bindings
    }

    method construct(%values) {
        for $.model.^attributes -> $attr {
            ...
            # HERE we need something to auto-coerce from SQL
        }
    }

    multi method find(%keys) {
        my ($where, @bindings) = self.process-where(%keys);

        my $columns = self.escaped-columns(:join<,>);
        my $sth = self.schema.dbh.prepare(qq:to/END_STATEMENT/);
            SELECT $columns
            FROM `$.escaped-table`
            $where
            END_STATEMENT

        $sth.execute(|@bindings);

        my %first = $sth.fetchrow-hash;
        my %second = $sth.fetchrow-hash;

        return Nil unless %first;
        die "more than a single row found by .find()" if %second;

        $.model.new(|%first, :sql-load);
    }

    multi method find(*%keys) { self.find(%keys) }

    method create(%values, Str :$onconflict) {
        my $row = $.model.new(|%values);

        my @columns = self.select-columns(%values);

        my $conflict = '';
        if defined $onconflict && $onconflict ~~ any(<ignore>) {
            $conflict = " OR " ~ uc $onconflict;
        }

        my $sth = $.schema.dbh.prepare(qq:to/END_STATEMENT/);
            INSERT$conflict INTO `$.escaped-table` (@columns.map(&sql-quote).join(','))
            VALUES (@columns.map({ '?' }).join(','))
            END_STATEMENT

        $sth.execute(|%values{ @columns });

        my $id = $.schema.last-insert-rowid;
        if $id == 0 && defined $onconflict {
            return self.find(%values);
        }

        $row.save-id($id);

        $row;
    }

    method update($row) {
        die "Wrong model; expected $.model but got $row.WHAT()"
            unless $row ~~ $.model;

        my $id-column-attr-name = $.model.HOW.id-column;
        my $id-column = $id-column-attr-name.substr(2);
        my $id-value  = $row."$id-column"();

        my ($where, @where-bindings) = self.process-where({
            $id-column => $id-value,
        });

        my @settings = $.model.^columns
            .grep({ .name ne $id-column-attr-name })
            .map(-> $col {
                my $getter = $col.name.substr(2);
                my $value  = $col.save-filter($row."$getter"());
                $col.column-name => $value;
            });

        my @set-names    = self.escaped-columns(@settings».key);
        my @set-bindings = @settings».value;

        my $sth = $.schema.dbh.prepare(qq:to/END_STATEMENT/);
            UPDATE `$.escaped-table`
               SET @set-names.map({ "{sql-quote($_)} = ?" }).join(',')
             $where
            END_STATEMENT

        $sth.execute(|@set-bindings, |@where-bindings);
    }

    method delete(:%where) {
        my ($where, @bindings) = self.process-where(%where);

        my $sql = qq:to/END_STATEMENT/;
            DELETE FROM `$.escaped-table`
            $where
            END_STATEMENT

        my $sth = $.schema.dbh.prepare($sql);

        $sth.execute(|@bindings);
    }

    multi method search(%search) returns ModelDB::Collection {
        ModelDB::Collection::Table.new(:table(self), :%search);
    }

    multi method search(*%search) { self.search(%search) }
}

class ModelDB::Collection::Table does ModelDB::Collection {
    has ModelDB::Table $.table;

    method all() {
        my ($where, @bindings) = $.table.process-where(%.search);

        my $columns = $.table.escaped-columns(:join<,>);
        my $sth = $.table.schema.dbh.prepare(qq:to/END_STATEMENT/);
            SELECT $columns
            FROM `$.table.escaped-table()`
            $where
            END_STATEMENT

        $sth.execute(|@bindings);

        $sth.allrows(:array-of-hash).map({ $.table.model.new(|$_, :sql-load) })
    }
}

