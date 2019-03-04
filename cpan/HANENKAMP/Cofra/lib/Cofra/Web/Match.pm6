use v6;

unit role Cofra::Web::Match;

method path-parameters(--> Hash:D) { ... }
method target(--> Callable:D) { ... }

=begin pod

=head1 NAME

Cofra::Web::Match - not yet documented

=head1 DESCRIPTION

This is the interface that routers must provide when matching incoming requests.

=head1 METHODS

=head2 method path-parameters

    method path-parameters(--> Hash:D)

This should return a L<Hash> containing any named parameters parsed out of the
path.

=head2 method target

    method target(--> Callable:D)

This should return a L<Callable> to be used to handle the endpoint. Normally,
this will be a subroutine returned by the L<target method|/Cofra::Web#method
target> of L<Cofra::Web>.

=end pod
