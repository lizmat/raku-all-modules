
use v6;

=begin pod

=head1 NAME

JSON::Infer::Role::Types

=head1 DESCRIPTION

=head2 METHODS


=head3 types

=head3 add-types

This takes and object of this role and adds it's types to my types.

=end pod

require JSON::Infer::Type;

role JSON::Infer::Role::Types {



    has @.types is rw;


    method  add-types(Mu:D $object ) {

        my $type-name = 'JSON::Infer::Type';

        if $object.does($?ROLE) {
            for $object.types -> $type {
                @!types.push($type);
            }
        }

        if $object.isa(::($type-name)) {
            @!types.push($object);
        }
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
