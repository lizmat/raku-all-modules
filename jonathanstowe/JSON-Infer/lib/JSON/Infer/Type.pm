
use v6;

=begin pod

=head1 NAME

JSON::Infer::Type

=head1 DESCRIPTION

This describes a L<Moose> typeconstraint;

=head2 METHODS

=over 4

=head3 name

This is the name of the typeconstraint that will be given to an attribute.


=head3 subtype_of

This is the type that the typeconstraint will be a subtype of.  This may be
undefined if this doesn't require to be a subtype.

=head3 array 

This is a boolean to indicate whether this is 
an array type.  This has a bearing on the coercion being created.

=head3 of_class

This is the L<JSON::Infer::Class> that this type is for.

=end pod

use JSON::Infer::Role::Entity;

class  JSON::Infer::Type does JSON::Infer::Role::Entity {

#    use JSON::Infer::Class;

    has Str $.subtype-of is rw handles(has-subtype => 'defined');
    has Bool $.array is rw = False;

    has $.of-class is rw;
}
# vim: expandtab shiftwidth=4 ft=perl6
