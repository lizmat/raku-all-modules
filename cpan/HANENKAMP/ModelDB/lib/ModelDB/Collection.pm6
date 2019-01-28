use v6;

unit package ModelDB;

=begin pod

=head1 NAME

ModelDB::Collection - a collection of models

=head1 SYNOPSIS

    use ModelDB;

    my ModelDB::Table[MyApp::Animals] $table .= new(...);
    my $collection = $table.search(:type<Pig>);
    for $collection.all -> $pig {
        say $pig.name;
    }

=head1 DESCRIPTION

Provides tool for iterating through a set of models. This is usually the result of a call to L<ModelDB::Table#method search>.

=head1 METHODS

=head2 method all

    method all(--> Seq)

Returns all model objects in a sequence.

=end pod

role Collection {
    has %.search;

    method all() { ... }
}

