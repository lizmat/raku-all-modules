use v6;

use Cofra::Web::Match;

unit role Cofra::Web::Request::Match[Cofra::Web::Match:D $match];

method match(--> Cofra::Web::Match:D) { $match }

method path-parameters(--> Hash:D) { $match.path-parameters }
method target(--> Callable:D) { $match.target }

=begin pod

=head1 NAME

Cofra::Web::Request::Match - request mixin to give the request access to router information

=head1 DESCRIPTION

This class is used to grant the information of a L<Cofra::Web::Match> to the
L<Cofra::Web::Request> to which it belongs once a router match has been made.

=head1 METHODS

=head2 method match

    method match(--> Cofra::Web::Match:D)

This is the L<Cofra::Web::Match> object that the router selected as matching the
current L<Cofra::Web::Request>.

=head2 method path-parameters

    method path-parameters(--> Hash:D)

This just returns the value of the C<path-parameters
method|Cofra::Web::Match#method path-parameters> of the wrapped
L<Cofra::Web::Match> object.

=head2 method path-parameters

    method target(--> Callable:D)

This just returns the value of the C<target method|Cofra::Web::Match#method
target> of the wrapped L<Cofra::Web::Match> object.

=head1 CAVEATS

It is unclear whether this is a good interface or not. It might be better to
just make this mixin role part of L<Cofra::Web::Request>, so there's every
likelihood this will disappear in favor of a different interface.

=end pod
