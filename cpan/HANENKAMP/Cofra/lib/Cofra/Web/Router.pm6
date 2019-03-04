use v6;

use Cofra::Web::Godly;

unit class Cofra::Web::Router does Cofra::Web::Godly;

use Cofra::Web::Match;
use Cofra::Web::Request;

method match(Cofra::Web::Request:D $request --> Cofra::Web::Match) { ... }

method path-for(%mapping --> Str) { ... }

=begin pod

=head1 NAME

Cofra::Web::Router - the interface for web routers

=head1 DESCRIPTION

In networking, a router is a device that takes signals from one cable and sends
those signals down other cables as needed. This class works like that in a way,
but it routes incoming signals that originated over a web protocol like HTTP/1.1
or HTTP/2 and decides which piece of code inside the application should
respond to it.

=head1 METHODS

=head2 method match

    method match(Cofra::Web::Request:D $request --> Cofra::Web::Match)

Given a L<Cofra::Web::Request>, this method should be implemented to try and
find some handler that can handle that request. It will then return a
L<Cofra::Web::Match> object describing that code. Along the way, it should parse
out any special parameters from the request to associate with the match itself.

If the router is able to find something to match, it should return a defined
object. If it cannot, it may return an undefined object. If it is able to find
multiple matches, it must be decisive and choose one. Remember, Cofra is a
humble and sensitive framework and doesn't like to let others know what opinions
it has. In this case, Cofra will simply not help you make a decision. If the
router can't decide, it should probably return no match. If it can, it should
return a single.

=head2 method path-for

    method path-for(%mapping --> Str)

I don't even know how to describe this without tying it directly into the only
router implementation I've build so far, so this is really just doing what
L<Path::Router> would do. That's really awful of me, but this is an MVP
implementation so it is what is is.

(MVP is not Most Valuable Player as it might be in certain Sportsball contests,
but Minimum Viable Product, which has the opposite meaning from the Sportsball
initialism, but used by nerdy software corporations, which are also the opposite
of Sportsball teams.)

=head1 CAVEATS

The whole C<.path-for> thing should really be resolved in a more satisfactory
way.

=end pod
