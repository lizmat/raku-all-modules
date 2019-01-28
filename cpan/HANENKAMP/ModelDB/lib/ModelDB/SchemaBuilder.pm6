use v6;

use ModelDB;

=begin pod

=head1 NAME

ModelDB::Builder - DSL for building models and schemas

=head2 SYNOPSIS

    use ModelDB::SchemaBuilder;

    class Schema is ModelDB::Schema {
        has ModelDB::Table[Person] $.persons is table;
    }

=head1 DESCRIPTION

Exports several subroutines that grant your module a useful vocabulary for quickly defining your schema objects.

=head1 EXPORTS

=head2 trait is table

    multi trait_mod:<is> (Attribute $attr, Str:D :$table!)
    multi trait_mod:<is> (Attribute $attr, :$table!)

This trait declares an attribute of the schema object to be a table object. If a string is passed to the trait, it names the table name to use within the database, otherwise, the name in the database is assumed to match the name of this attribute exactly.

=end pod

module ModelDB::SchemaBuilder { }

multi trait_mod:<is> (Attribute $attr, Str:D :$table!) is export {
    $attr does ModelDB::TableBuilder[$table]
}

multi trait_mod:<is> (Attribute $attr, :$table!) is export {
    $attr does ModelDB::TableBuilder[$attr.name.substr(2)]
}

