
use v6;

=begin pod

=head1 NAME

JSON::Infer::Role::Entity

=head1 DESCRIPTION

Role for common items between classes (name etc.)

=head2 METHODS


=head3 name

=end pod

role JSON::Infer::Role::Entity {

   has Str $.name is rw;

}
# vim: expandtab shiftwidth=4 ft=perl6
