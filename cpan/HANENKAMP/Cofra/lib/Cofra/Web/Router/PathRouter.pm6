use v6;

use Cofra::Web::Router;

unit class Cofra::Web::Router::PathRouter is Cofra::Web::Router;

use Path::Router;
use Cofra::Web::Match::PathRouterRouteMatch;

has $.router-class;
has $.router;

submethod BUILD(:$!router-class = Path::Router, :$!router) {
    $!router = $!router-class.new without $!router;
}

has Bool $!has-been-initialized = False;
method !initialize-routes(Cofra::Web::Router:D:) {
    return if $!has-been-initialized++;

    my $*ROUTER = self;

    for self.^mro.reverse {
        .ROUTE if .^find_method('ROUTE', :no_fallback);
    }

    True;
}

multi method add-route(Str:D $REQUEST_METHOD, Str:D $path, %options --> True) {
    my %conditions = %( :$REQUEST_METHOD );

    # TODO This feels really sketchy
    my $target = do if %options<taget>:exists {
        $.web.target(|%options<target>);
    }
    else {
        $.web.target(|%options<defaults>);
    }

    $.router.add-route($path, %( |%options, :$target, :%conditions ));
}

multi method add-route(|c --> True) {
    $.router.add-route(|c);
}

method match(Cofra::Web::Request:D $request --> Cofra::Web::Match) {
    self!initialize-routes;

    my $match = $.router.match($request.path, context => $request.router-context);
    return Nil without $match;
    Cofra::Web::Match::PathRouterRouteMatch.new(:$match);
}

method path-for(%path-parameters --> Str) {
    self!initialize-routes;

    $.router.path-for(%path-parameters);
}

sub get(+%route --> True) is export {
    $*ROUTER.add-route('GET', .key, .value) for %route;
}

sub put(+%route --> True) is export {
    $*ROUTER.add-route('PUT', .key, .value) for %route;
}

sub post(+%route --> True) is export {
    $*ROUTER.add-route('POST', .key, .value) for %route;
}

sub delete(+%route --> True) is export {
    $*ROUTER.add-route('DELETE', .key, .value) for %route;
}

=begin pod

=head1 NAME

Cofra::Web::Router::PathRouter - implementation of Cofra::Web::Router using Path::Router

=head1 DESCRIPTION

This uses L<Path::Router> to implement L<Cofra::Web::Router>. As of this
writing, there are no other options for this task, so you might notice an
astonish similarity between the interfaces. This is probably bad. It shoudl be
fixed.

As I write this, I imagine a future in which I fix this problem because really
it ought to be more generic than that. I also imagine a future in which I am
eating a large burrito. Lord willing, the burrito is going to happen and happen
soon. I make no guarantees on that other thing I was imagining but now I have
forgotten about because of the burrito.

=head1 METHODS

=head2 method router-class

    has $.router-class

This should be set to the package naming the class we will use to construct the
router. It will be set to L<Path::Router> by default.

=head2 method router

    has $.router

This is the constructed router object. It will probably be a L<Path::Router>
object unless you do something funny with the L<router-class attribute|#method
router-class>.

(I mean "unusual funny" not "hilarious funny" nor "I-feel-kinda-sick funny" in
case that's unclear.)

=head2 method add-route

    method add-route(Str:D $REQUEST_METHOD, Str:D $path, %options --> True)

Defines a new route for the router given a C<$REQUEST_METHOD> to match and a C<$path>. The L<%options> define additional settings to pass through the router object. These include:

=defn C<target>

This defines the target setting to use.

=defn C<defaults>

This defines default path-parameters to ouse.

=head2 method match

    method match(Cofra::Web::Request:D $request --> Cofra::Web::Match)

This will return a defined L<Cofra::Web::Match::PathRouterRouteMatch> if the
router is able to find a path match. It will return an undefined
L<Cofra::Web::Match> type object if not. It may throw an exception if the
request ambiguously matches multiple routes.

=head2 method path-for

    method path-for(%path-parameters --> Str)

This is able to give you a relative link from the given C<%path-parameters>. I
don't know what will happen with this. It feels a little iffy that I will leave
it as is, though.

=head2 sub get

    sub get(+%route --> True) is export

=head2 sub put

    sub put(+%route --> True) is export

=head2 sub post

    sub post(+%route --> True) is export

=head2 sub delete

    sub delete(+%route --> True) is export

=head1 CAVEATS

This has nothing to do with anything useful, but whether you pronounce router
the American way, "Rauwterrr" or the British way, "Roooootah" or the Nigerian
way or whatever the weird Canadian way doesn't matter (and don't get me started
on Australians). Cofra still loves you anyway.

Also fun fact, Nigeria is the second largest country whose primary language is
English, though there are more English speakers by absolute in India, Pakistan,
and the Phillipines. The country containing England has slipped down to #5 on
the list of English speaking countries sorted by population even though the
language is named after them.

And another fun fact, England is named after the Angles who sort of moved in and
took over that area of the word from the natives who had only recently stopped
being part of the Roman empire, but no one is really certain what an Angle is or
where they came from. Wikipedia makes it sound like we're more sure, but that's
just summarizing all the guesses historians have made over the past few hundred
years as if any of those historians were doing more than just clinching their
bottoms real hard and saying, "There's not much evidence to say they came from
anywhere, but..."

Another fun fact, I'm not a historian or a linguist I just make stuff up as I go
like the rest of you, so take all that how you like.

=end pod
