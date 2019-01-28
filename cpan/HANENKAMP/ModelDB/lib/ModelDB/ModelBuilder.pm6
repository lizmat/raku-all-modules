use v6;

use ModelDB;
use MetamodelX::DBModelHOW;

=begin pod

=head1 NAME

ModelDB::ModelBuilder - DSL for building models

=head2 SYNOPSIS

    use ModelDB::ModelBuilder;

    model Person {
        has Int $.person-id is column is primary;
        has Str $.name is column;
        has Str $.favorite-color is column;
    }

=head1 DESCRIPTION

Exports several subroutines that grant your module a useful vocabulary for quickly defining your models objects.

=head1 EXPORTS

=head2 model

    model YourModel { ... }

This defines a model declarator which defines a class-like object for storing information about each model.

=head2 sub belongs-to

    sub belongs-to(
        Str :$relationship,
        Str :$local-index,
        Mu :$foeign-class,
        Str :$foreign-index = 'PRIMARY',
    )

TODO This is busted.

=head2 trait is column

    multi trait_mod:<is> (Attribute $attr, Str:D :$column!)
    multi trait_mod:<is> (Attribute $attr, :$column!)

This adds the attribute as a column of a model. If a string is passed to the trait, that string will be used as the name of the column in the database. Otherwise, the column name in the database will be assumed to match the attribute name.

=head2 trait is primary

    multi trait_mod:<is> (Attribute $attr, :$primary!)

This marks the column as being a member of the primary key. As of this writing, only a single column may be part of the primary, but this limitation may be lifted in the future.

=end pod

module ModelDB::ModelBuilder { }

sub belongs-to(
    Str :$relationship,
    Str :$local-index,
    Mu :$foreign-class,
    Str :$foreign-index = 'PRIMARY',
) is export {
    my \type = callframe(1).my<?::PACKAGE>;

    my $relationship-key;
    type.^add_method("_set-key-for-$relationship", method ($key) {
        $relationship-key = $key;
    });

    type.^add_method($relationship, method (ModelDB::Schema $schema = $*DB-SCHEMA) {
        my @theirs = $foreign-class.^index{ $foreign-index };
        my @ours   = self.^index{ $local-index };

        my %key = zip(@theirs, @ours).map: -> ($their-attr, $our-attr) {
            my $their-key = $their-attr.name.substr(2);
            my $our-key   = $our-attr.name.substr(2);
            my $value     = self."$our-key"();

            $their-key => $value;
        };

        $schema."$relationship-key"().find(|%key);
    });
}

multi trait_mod:<is> (Attribute $attr, Str:D :$column!) is export {
    die "columns must be added to models" unless $attr.package.HOW ~~ MetamodelX::DBModelHOW;
    $attr does ModelDB::Column[$column];
}

multi trait_mod:<is> (Attribute $attr, :$column!) is export {
    die "columns must be added to models" unless $attr.package.HOW ~~ MetamodelX::DBModelHOW;
    $attr does ModelDB::Column[$attr.name.substr(2)];
}

multi trait_mod:<is> (Attribute $attr, :$primary!) is export {
    $attr.package.HOW.id-column = $attr.name;
    $attr.package.HOW.index<PRIMARY> = [ $attr ];
}

# This syntax sucks. I'm hiding it for now.
# multi trait_mod:<is> (Attribute $attr, :@indexed!) is export {
#     my ($index-name, $pos) = |@indexed;
#     die "index name is required" without $index-name;
#     $attr.package.HOW.index{ $index-name } //= [];
#     $pos //= $attr.package.HOW.index{ $index-name }.elems;
#     $attr.package.HOW.index{ $index-name }[ $pos ] = $attr;
# }
#
# multi trait_mod:<is> (Attribute $attr, :$indexed!) is export {
#     my $index-name = $attr.name.substr(2);
#     $attr.package.HOW.index{ $index-name } = [ $attr ];
# }
#
# multi trait_mod:<is> (Attribute $attr, :@related!) is export {
#     my ($relationship-name, $schema-ref) = |@related;
#     $attr does ModelDB::RelationshipSetup[$relationship-name, $schema-ref];
# }

package EXPORTHOW {
    package DECLARE {
        constant model = MetamodelX::DBModelHOW;
    }
}

