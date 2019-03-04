use v6;

use Cofra::Web::Match;

unit class Cofra::Web::Match::PathRouterRouteMatch does Cofra::Web::Match;

use Path::Router;

has Path::Router::Route::Match $.match is required;

method path-parameters(--> Hash:D) { $.match.mapping }
method route(--> Path::Router::Route:D) { $.match.route }
method target(--> Callable:D) { $.match.target }

=begin pod

=head1 NAME

Cofra::Web::Match::PathRouterRouteMatch - router match class for Path::Router matches

=head1 DESCRIPTION

This is a L<Cofra::Web::Match> object used by L<Cofra::Web::Router::PathRouter>.
This class is really like one of those silicone masks on Mission Impossible. It
looks like the bad guy, but it's really the hero in disguise.

=head1 METHODS

=head2 method match

    has Path::Router::Route::Match $.match is required

This class fulfills the adapter pattern to map the L<Path::Router::Route::Match>
object to the L<Cofra::Web::Match> interface.

=head2 method path-parameters

    method path-parameters(--> Hash:D)

Returns the value of the C<mapping> attribute of the wrapped
L<Path::Router::Route::Match>.

=head2 method route

    method route(--> Path::Router::Route:D)

This is the value of the C<route> attribute of the wrapped
L<Path::Router::Route::Match>.

=head2 method target

    method target(--> Callable:D)

This is the value of the C<target> attribute of the wrapped
L<Path::Router::Route::Match>.

=head1 CAVEATS

This belongs in a separate Cofra-Web-Router-PathRouter distribution and will be
moved to such some day.

=end pod
