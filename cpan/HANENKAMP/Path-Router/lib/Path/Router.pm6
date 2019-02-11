use v6;
unit class Path::Router:ver<0.4.0>:auth<github:zostay>;

use Path::Router::Route;
use X::Path::Router;

our $DEBUG = ?%*ENV<PATH_ROUTER_DEBUG>;

has Path::Router::Route @.routes;
has $.route-class = Path::Router::Route;

multi method add-route(Str $path, *%options --> Int) {
    @!routes.push: $!route-class.new(
        path => $path,
        |%options,
    );
    @!routes.elems;
}

multi method add-route(Str $path, %options --> Int) {
    self.add-route($path, |%options);
}

multi method add-route(*@pairs, *%pairs --> Int) {
    for (|@pairs, |%pairs)».kv -> (Str $path, %options) {
        self.add-route($path, |%options);
    }
    @!routes.elems;
}

multi method insert-route(Str $path, Int :$at = 0, *%options --> Int) {
    my $route = $!route-class.new(
        path => $path,
        |%options,
    );

    given $at {
        when 0                { @!routes.unshift: $route }
        when @!routes.end < * { @!routes.push: $route }
        default               { @!routes.splice($at, 0, $route) }
    }

    @!routes.elems;
}

multi method insert-route(Str $path, %options --> Int) {
    self.insert-route($path, |%options);
}

multi method insert-route(*@pairs, *%pairs --> Int) {
    for (|@pairs, |%pairs)».kv -> (Str $path, %options) {
        self.insert-route($path, |%options);
    }

    @!routes.elems;
}

multi method include-router(Str $path, Path::Router $router --> Int) {
    ($path eq '' || $path ~~ /\/$$/)
        || die X::Path::Router::BadInclusion.new;

    @!routes.push(
        |$router.routes.map: {
            my %attr = .copy-attrs;
            %attr<path> = $path ~ %attr<path>;
            .new(|%attr)
        }
    );

    @!routes.elems;
}

multi method include-router(Pair $pair --> Int) {
    my (Str $path, Path::Router $router) = $pair.kv;
    self.include-router($path, $router);
}

method match(Str $path is copy, :%context --> Path::Router::Route::Match) {
    $path  = IO::Spec::Unix.canonpath($path, :parent);
    $path .= subst(/^\//, '');

    my Str @parts = $path.comb(/ <-[ \/ ]>+ /);

    my Path::Router::Route::Match @matches;
    for @!routes -> $route {
        my $match = $route.match(@parts, :%context) orelse next;
        @matches.push: $match;
    }

    return Nil                        if @matches.elems == 0;
    return @matches[0]                if @matches.elems == 1;
    return self!disambiguate-matches($path, @matches);
}

method !disambiguate-matches(Str $path, Path::Router::Route::Match @matches --> Path::Router::Route::Match) {
    my Int $min;
    my Path::Router::Route::Match @found;

    for @matches -> $match {
        my $vars = $match.route.required-variable-component-names.elems;
        if !$min.defined || $vars < $min {
            @found = $match;
            $min = $vars;
        }
        elsif $vars == $min {
            @found.push: $match;
        }
    }

    if @found.elems == 2
    && @found[0].route.has-conditions != @found[1].route.has-conditions {
        return @found[0] if @found[0].route.has-conditions;
        return @found[1];
    }

    die X::Path::Router::AmbiguousMatch::PathMatch.new(
        :matches(@found), :$path
    ) if @found.elems > 1;

    @found[0];
}

method !try-route(%path-map is copy, %context, Path::Router::Route $route --> Str) {
    my @path;

    my sub debug { note [~] @_ if $DEBUG }

    if $route.has-conditions && %context {
        unless $route.test-conditions(%context) {
            debug("conditions failed");
            return Nil;
        }
    }

    my $required = $route.required-variable-component-names;
    my $optional = $route.optional-variable-component-names;

    my %path-defaults;

    my %match = $route.defaults;

    for |$required.keys, |$optional.keys -> $component {
        next unless %match{$component} :exists;
        %path-defaults{$component} = %match{$component} :delete;
    }
    # any remaining keys in %defaults are 'extra' -- they don't
    # appear in the path, so they need to match exactly rather
    # than being filled in

    %path-map = |%path-defaults, |%path-map;

    my @keys = |%path-map.keys;

    my class X::RouteNotMatched is Exception {
        has Str $.reason;
        method new($reason) {
            self.bless(:$reason);
        }
        method message() { $!reason }
    }

    debug("> Attempting to match ", $route.path, " to (", @keys.join(" / "), ")");

    (
        $required.elems <= @keys.elems <= $required.elems + $optional.elems + %match.elems
    ) || die X::RouteNotMatched.new("LENGTH DID NOT MATCH ({$required.elems} required {$required.elems <= @keys.elems ?? "≤" !! "≰"} {@keys.elems} keys {@keys.elems <= $required.elems + $optional.elems + %match.elems ?? "≤" !! "≰"} {$required.elems} required + {$optional.elems} optional + {%match.elems} match)"); #>>>>

    if my @missing = $required.keys.grep({ !(%path-map{$_} :exists) }) {
        debug("missing: {@missing}");
        die X::RouteNotMatched.new("MISSING ITEM [{@missing}]");
    }

    if my @extra = %path-map.keys.grep({
        $_ ∉ $required && $_ ∉ $optional && !%match{$_}
    }) {
        debug("extra: {@extra}");
        die X::RouteNotMatched.new("EXTRA ITEM[{@extra}]");
    }

    if my @nomatch = %match.keys.grep({
        %path-map{$_} :exists and %path-map{$_} ne %match{$_}
    }) {
        debug("no match: {@nomatch}");
        die X::RouteNotMatched.new("NO MATCH[{@nomatch}]");
    }

    for $route.components -> $component {
        if $route.is-component-variable($component) {
            debug("\t\t... found a variable ($component)");
            my $name = $route.get-component-name($component);

            unless $route.is-component-optional($component)
                && $route.defaults{$name}
                && $route.defaults{$name} eq %path-map{$name}
            {
                my $c = %path-map{$name};
                $c = join '/', @($c)
                    if $route.is-component-slurpy($component);
                @path.push: $c;
            }
        }

        else {
            debug("\t\t... found a constant ($component)");

            @path.push: $component;
        }

        debug("+++ URL so far ... ", @path.join("/"));
    }

    CATCH {
        when X::RouteNotMatched {
            debug('URL: ', @path.join("/"));
            debug("... ", $_);

            return Nil;
        }
    }

    @path.grep({ .defined }).join("/");
}

method uri-for(*%path-map --> Str) is DEPRECATED("'path-for'") {
    self.path-for(|%path-map);
}

multi method path-for(:%context, *%path-map is copy --> Str) {
    self.path-for: %( |%path-map, :%context);
}

multi method path-for(%pm (:%context, *%path-map) --> Str) {

    # anything => Nil is useless; ignore it and let the defaults override it
    for %path-map.keys {
        %path-map{$_} :delete unless %path-map{$_}.defined;
    }

    my @possible = gather for @!routes -> $route {
        my $path = self!try-route(%path-map, %context, $route);
        take $[ $route, $path ] with $path;
    }

    return Nil unless @possible;
    return @possible[0][1] if @possible == 1;

    my @found;
    my $min;
    for @possible -> $possible {
        my ($route, $path) = @($possible);

        temp %path-map = %path-map;

        my $required = $route.required-variable-component-names;
        my $optional = $route.optional-variable-component-names;

        my %path-defaults;

        my %match = $route.defaults;

        for $required.list, $optional.list -> $component {
            next unless %match{$component} :exists;
            %path-defaults{$component} = %match{$component} :delete;
        }
        # any remaining keys in %defaults are 'extra' -- they don't appear
        # in the path, so they need to match exactly rather than being filled
        # in

        %path-map = |%path-defaults, |%path-map;

        my $wanted = ($required.list ∪ $optional.list ∪ set %match.keys).SetHash;
        $wanted{$_} :delete for %path-map.keys;

        if (!$min.defined || $wanted.elems < $min) {
            @found = $possible;
            $min = $wanted.elems;
        }
        elsif ($wanted.elems == $min) {
            push @found, $possible;
        }
    }

    die X::Path::Router::AmbiguousMatch::ReverseMatch.new(
        match-keys => %path-map.keys,
        routes     => @found,
    ) if @found > 1;

    @found[0][1];
}

=begin pod

=NAME Path::Router - A tool for routing paths

=begin SYNOPSIS

  my $router = Path::Router.new;

  $router.add-route('blog' => %(
      conditions => %( :method<GET> ),
      defaults => {
          controller => 'blog',
          action     => 'index',
      },
      # you can provide a fixed "target"
      # for a match as well, this can be
      # anything you want it to be ...
      target => My::App.get_controller('blog').get_action('index')
  ));

  $router.add-route('blog/:year/:month/:day' => %(
      conditions => %( :method<GET> ),
      defaults => {
          controller => 'blog',
          action     => 'show_date',
      },
      # validate with ...
      validations => {
          # ... raw-Regexp refs
          year       => rx/\d ** 4/,
          # ... custom types you created
          month      => NumericMonth,
          # ... anon-subsets created inline
          day        => (anon subset NumericDay of Int where * <= 31),
      }
  ));

  $router.add-route('blog/:action/?:id' => %(
      defaults => {
          controller => 'blog',
      },
      validations => {
          action  => rx/\D+/,
          id      => Int,  # also use Perl6 types too
      }
  ));

  # even include other routers
  $router.include-router( 'polls/' => $another_router );

  # ... in your dispatcher

  # returns a Path::Router::Route::Match object
  my $match = $router.match('/blog/edit/15', context => %( method => 'GET' ));

  # ... in your code

  my $uri = $router.path-for(
      controller => 'blog',
      action     => 'show_date',
      year       => 2006,
      month      => 10,
      day        => 5,
  );

=end SYNOPSIS

=begin DESCRIPTION

This module provides a way of deconstructing paths into parameters
suitable for dispatching on. It also provides the inverse in that
it will take a list of parameters, and construct an appropriate
uri for it.

=head2 Reversable

This module places a high degree of importance on reversability.
The value produced by a path match can be passed back in and you
will get the same path you originally put in. The result of this
is that it removes ambiguity and therefore reduces the number of
possible mis-routings.

=head2 Verifiable

This module also provides additional tools you can use to test
and verify the integrity of your router. These include:

=item An interactive shell in which you can test various paths and see the
match it will return, and also test the reversability of that match.

=item A L<Test::Path::Router> module which can be used in your applications
test suite to easily verify the integrity of your paths.

=head2 Validated and Automatically Coerced

Each path may use one or more variables, each given a validation. If a numeric
type is used, the value passed on to the action will also be coerced into the
correct value.

=head2 Flexible

This module has no opinions about what it might be useful for. It simply produces a hash of values that can be used for dispatch, logging, or whatever your application is.

=end DESCRIPTION

=head1 ATTRIBUTES

=head2 routes

    has Path::Router::Route @.routes

Stores all the route objects that have been added to the router.

=head1 METHODS

=head2 method add-route

    method add-route(Str $path, *%options --> Int)

Adds a new route to the I<end> of the routes list.

Returns the number of routes stored.

=head2 method insert-route

    method insert-route(Str $path, *%options --> Int)

Adds a new route to the routes list. You may specify an C<at> parameter, which would
indicate the position where you want to insert your newly created route. The C<at>
parameter is the C<index> position in the list, so it starts at 0.

Returns the number of routes stored.

Examples:

    # You have more than three paths, insert a new route at
    # the 4th item
    $router.insert-route($path => %(
        at => 3, |%options
    ));

    # If you have less items than the index, then it's the same as
    # as add_route -- it's just appended to the end of the list
    $router.insert-route($path => %(
        at => 1_000_000, |%options
    ));

    # If you want to prepend, omit "at", or specify 0
    $router.insert-route($path => %(
        at => 0, |%options
    ));

=head2 method include-router

    method include-router (Str $path, Path::Router $other-router --> Int)

This extracts all the route from C<$other-router> and includes them into
the invocant router and prepends C<$path> to all their paths.

It should be noted that this does B<not> do any kind of redispatch to the
C<$other-router>, it actually extracts all the paths from C<$other-router>
and inserts them into the invocant router. This means any changes to
C<$other-router> after inclusion will not be reflected in the invocant.

Returns the number of routes stored.

=head2 method match

    method match(Str $path, :%context --> Path::Router::Route::Match)

Return a L<Path::Router::Route::Match> object for the best route that matches
the given the C<$path> and C<%context> (if given), or an undefined type-object
if no routes match.

The C<%context> is an optional value that is only used if routes with conditions are present. The context is used as an additional match in the process and can be used to apply extra conditions, such as matching the HTTP method when used in a web application.

The "best route" is chosen by first matching the C<$path> against every route and then applying the following rules:

=over

=item If no route matches, an undefined type object will be returned. If exactly
one route matches, a match for that route will be returned.

=item If multiple routes match, the one with the most required variables will be
considered the best match and be returned.

=item In the case that exactly two routes match and have the same number of
variables, but one has conditions and the other does not, the one that has
conditions will be considered best and returned.

=item Otherwise, if there is more than one matching route with the same number
of required variables, an L<#X::Path::Router::AmbiguousMatch::PathMatch>
exception is thrown. This exception contains all the best matches, so your code
can disambiguate them in any way you want or treat this as an error condition as
suits your application.

=head2 method path-for

    method path-for(:%context, *%path_descriptor --> Str)

Find the path that, when passed to C<< method match >>, would produce the
given arguments.  Returns the path without any leading C</>.  Returns an
undefined type-object if no routes match.

The C<%context> is optional, but if present, this will also apply any route conditions to the given C<%context>.

This will throw an L<#X::Path::Router::AmbiguousMatch::ReverseMatch> exception if
multiple URLs match. This exception includes the possible routes so your code
can disambiguate them in whatever fashion makes sense to you.

=head1 DEBUGGING

You can turn on the verbose debug logging with the C<PATH_ROUTER_DEBUG>
environment variable. Set that environment variable to a truthy value to enable
debugging.

=begin DIAGNOSTIC

=head2 X::Path::Router

All path router exceptions inherit from this exception class.

=head2 X::Path::Router::AmbiguousMatch::PathMatch

This exception is thrown when a path is found to match two different routes equally well.

Provides:

=item C<< method path(--> Str) >> returns the ambiguous path.

=item C<< method matches(--> Array) >> returns the best matches found.

=head2 X::Path::Router::AmbiguousMatch::ReverseMatch

This exception is thrown when two paths are found to match a given criteria when looking up the C<path-for> a path

Provides:

=item C<< method match-keys(--> Array[Str]) >> returns the mapping that was ambiguous

=item C<< method routes(--> Array[Str]) >> returns the best matches found

=head2 X::Path::Router::BadInclusion

This exception is thrown whenever an attempt is made to include one router in another incorrectly.

=head2 X::Path::Router::BadRoute

This exception is thrown when a route has some serious flaw.

Provides:

=item C<< method path(--> Str) >> returns the bad route

=head2 X::Path::Router::BadValidation

This is an L<#X::Path::Router::BadRoute> exception that is thrown when a validation for a variable that is not found in the path.

Provides:

=item C<< method validation(--> Str) >> returns the validation variable that was named in the route, but was not found in the path

=head2 X::Path::Router::BadSlurpy

This is an L<#X::Path::Router::BadRoute> exception that is thrown when a validation attempts to add a slurpy parameter that is not at the end of the path.

=end DIAGNOSTIC

=begin AUTHOR

Andrew Sterling Hanenkamp E<lt>hanenkamp@cpan.orgE<gt>

Based very closely on the original Perl 5 version by
Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

=end AUTHOR

=for COPYRIGHT
Copyright 2015 Andrew Sterling Hanenkamp.

=for LICENSE
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=end pod
