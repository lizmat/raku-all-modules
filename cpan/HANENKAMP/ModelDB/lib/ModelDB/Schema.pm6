use v6;

unit package ModelDB;

=begin pod

=head1 NAME

ModelDB::Schema - a schema ties models to tables on a particular DB connection

=head1 DESCRIPTION

A schema is a collection of models.

Each model is tied to a table. A model object may be tied to multiple tables if they have the same RDBMS schema.

When instantiated, a schema object is tied to a specific database connection. Multiple schemas can be created to connect to different databases. This can be useful if you have read replicas, for example.

=head1 METHODS

=head2 method dbh

    has $.dbh is required

This is the L<DBIish> database handle the schema talks through.

=head2 method last-insert-rowid

    method last-insert-rowid(--> Any)

TODO This does not belong here.

This is a method for fetching the last insert ID following an insert operation.

=end pod

class Schema {
    has $.dbh is required;

    method last-insert-rowid() {
        my $sth = $.dbh.prepare('SELECT last_insert_rowid()');
        $sth.execute;
        $sth.fetchrow[0];
    }
}

