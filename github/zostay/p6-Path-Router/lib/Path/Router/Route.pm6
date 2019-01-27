use v6;

use X::Path::Router;

class Path::Router::Route { ... }

class Path::Router::Route::Match {
    has Str $.path;
    has %.mapping;
    has Path::Router::Route $.route handles <target>;
}

class Path::Router::Route {

    has Str $.path;
    has %.defaults; # is copy
    has %.validations; # is copy
    has %.conditions;
    has Str @.components = self!build-components(); # is no-clone
    has Int $.length = self!build-length; # is no-clone
    has Int $.length-without-optionals = self!build-length-without-optionals; # is no-clone
    has $.required-variable-component-names = self!build-required-variable-component-names; # is no-clone
    has $.optional-variable-component-names = self!build-optional-variable-component-names; # is no-clone
    has $.target;

    method copy-attrs(--> Hash) {
        return (
            path        => $!path,
            defaults    => %!defaults.clone,
            validations => %!validations.clone,
            target      => $!target,
        ).hash;
    }

    method has-defaults(--> Bool) {
        ?%!defaults;
    }

    method has-validations(--> Bool) {
        ?%!validations;
    }

    method has-conditions(--> Bool) {
        ?%!conditions;
    }

    submethod TWEAK {
        self!validate-configuration;
    }

    submethod !validate-configuration {
        # If there's a slurpy, it had better be the last one
        die X::Path::Router::BadSlurpy.new(:$!path)
            if @!components > 1
            && self.is-component-slurpy(@!components[0..*-2].any);

        return unless self.has-validations;

        # Get the names of all the variable components
        my $components = set @!components.grep({
            self.is-component-variable($^comp)
        }).map({
            self.get-component-name($^comp)
        });

        # Make we only have validations for variables in the path
        for %!validations.keys -> $validation {
            if $validation ∉ $components {
                die X::Path::Router::BadValidation.new(:$validation, :$!path);
            }
        }
    }

    method !build-components {
        $!path.comb(/ <-[ \/ ]>+ /).grep({ .chars });
    }

    method !build-length {
        @!components.elems;
    }

    method !build-length-without-optionals {
        @!components.grep({ !self.is-component-optional($^component) }).elems;
    }

    method !build-required-variable-component-names {
        return set @!components.grep({
             self.is-component-variable($^comp) &&
            !self.is-component-optional($comp)
        }).map({
            self.get-component-name($^comp)
        });
    }

    method !build-optional-variable-component-names {
        return set @!components.grep({
            self.is-component-variable($^comp) &&
            self.is-component-optional($comp)
        }).map({
            self.get-component-name($^comp)
        });
    }

    # misc

    method create-default-mapping(--> Hash) {
        %(%!defaults.map({ .key => .value.clone }));
    }

    method has-validation-for(Str $name --> Bool) {
        %!validations{$name} :exists
    }

    # component checking

    method is-component-slurpy(Str $component --> Bool) {
        ?($component ~~ / ^ <[*+]> \: /);
    }

    method is-component-optional(Str $component --> Bool) {
        ?($component ~~ / ^ <[*?]> \: /);
    }

    method is-component-variable(Str $component --> Bool) {
        ?($component ~~ / ^ <[?*+]> ? \: /);
    }

    method get-component-name(Str $component --> Str) {
        $component ~~ / ^ <[?*+]> ? \: $<name> = [ .* ] $$ /;
        ~$<name>;
    }

    method has-slurpy-match(--> Bool) {
        return False unless @!components;
        self.is-component-slurpy(@!components[*-1])
    }

    method test-conditions(%context --> Bool) {
        [&&] gather for %!conditions.kv -> $key, $match {
            my $value = %context{ $key };
            take $value ~~ $match;
        }
    }

    method match(@parts, :%context --> Path::Router::Route::Match) {
        # No match if the parts length is not long enough
        return Nil unless @parts >= $!length-without-optionals;

        # No match if parts is too long (unless we're slurpy, then it's fine)
        return Nil unless self.has-slurpy-match || $!length >= @parts;

        # Build the default mapping, shallow cloning any refs
        my %mapping = $.has-defaults ?? self.create-default-mapping !! ();

        # a working copy of parts we'll shift from as we go
        my @wc-parts = @parts;

        # If it has conditions, test those first.
        if $.has-conditions {

            # short-circuit to no match if conditional match fails
            return Nil unless self.test-conditions(%context);
        }

        for @!components -> $c {
            unless @wc-parts {
                die "should never get here: " ~
                    "no @parts left, but more required components remain"
                        if ! self.is-component-optional($c);
                last;
            }

            my $part;

            # Slurpy sucks up the rest of the parts
            if self.is-component-slurpy($c) {
                $part = @wc-parts.clone.List;
                @wc-parts = ();
            }

            # Or just get the next part
            else {
                $part = @wc-parts.shift;
            }

            # If this is a variable, process it
            if self.is-component-variable($c) {

                # The variable name
                my $name = self.get-component-name($c);

                # Validate the value for the variable if needed
                if self.has-validation-for($name) {
                    my $v = %!validations{$name};

                    # Automatically coerce the value first, if needed
                    my $test-part = $part;
                    try {
                        given $v {
                            when UInt { $test-part .= UInt }
                            when Int  { $test-part .= Int  }
                            when Num  { $test-part .= Num  }
                            when Real { $test-part .= Real }
                            when Rat  { $test-part .= Rat  }
                        }
                    }

                    # Apply the validation check
                    my $match = $test-part ~~ $v;

                    # Regexes must be a total match
                    if ($match ~~ Match) {
                        return Nil
                            unless $match && $match eq $test-part;
                    }

                    # Anything else matches whatever it matches
                    else {
                        return Nil unless $match;
                    }

                    # store the coerced version
                    $part = $test-part;
                }

                # Variable is valid and ready to map
                %mapping{$name} = $part;
            }

            # Otherwise, path must eq component
            else {
                return Nil unless $c eq $part;
            }
        }

        # Successful match, construct and return
        return Path::Router::Route::Match.new(
            path    => @parts.join('/'),
            route   => self,
            mapping => %mapping,
        );
    }

}

=begin pod

=TITLE Path::Router::Route;

=SUBTITLE An object to represent a route

=begin DESCRIPTION

This object is created by L<Path::Router> when you call the
C<add-route> method. In general you won't ever create these objects
directly, they will be created for you and you may sometimes
introspect them.

=end DESCRIPTION

=head1 ATTRIBUTES

=head2 path

    has Str $.path

This is the full path of the route.

=head2 target

    has $.target

This is the configured target for the route. This does not have to be set and is
not used by the tooling except to return when matching a route.

=head2 components

    has Str @.components

This is the list of components, basically, all the path parts between "/".

=head2 length

    has Int $.length

This is the maximum length of path this route can match (unless it's slurpy,
then the path has upper limit).

=head2 length-without-optionals

    has Int $.length-without-optionals

This is the minimum length of path this route can match.

=head2 default

    has %.defaults

These are the defaults provided for the path. These will used both for path
matching and path building.

=head2 validations

    has %.validations

This defines any validations the route needs to perform for each variable. For
C<Int>, C<UInt>, C<Rat>, C<Real>, and C<Num>, it will also cause coercion to
happen on the incoming path components.

=head2 conditions

    has %.conditions

This defined any conditions to set on the route. When conditions are set, the
conditions are matched against the C<%context> argument that may be passed to
L<#method match>. Any condition that fails to match will cause the route to fail
to match. This can be useful, for example, for matching against request method
when used to match HTTP requests.

=head1 METHODS

=head2 method has-defaults

    method has-defaults(--> Bool)

Returns C<True> if this route has any defaults.

=head2 method has-validations

    method has-validations(--> Bool)

Returns C<True> if this route has any validations.

=head2 method has-validation-for

    method has-validation-for(Str $name --> Bool)

Returns C<True> if this route has a validation with the given C<$name>.

=head2 method has-conditions

    method has-conditions(--> Bool)

Returns C<True> if this route has at least one condition set.

=head2 method test-conditions

    method test-conditiosn(%context --> Bool)

Given a context to test agains, this will test that context against the conditions set on the route. This test should only be executed if C<has-conditions> returns C<True>.

=head2 method match

    method match(@parts, :%context --> Path::Router::Route::Match)

Returns a defined L<Path::Router::Route::Match> if this route matches the given
path parts. Returns an undefined type-object otherwise.

You may provide an optional C<%context> value when matching. This value is
ignored unless the route being match as a L<#condition> set. In that case, the
conditions are checked against the context. If any condition fails to match, the
route will not match.

=head1 Component checks

These methods are called on components, which can be gotten from the
L<#components> attribute.

=head2 method get-component-name

    method get-component-name(Str $component --> Str)

This method will return the variable name of a component for components for
which L<#method is-component-variable> is C<True>. Do not use this method unless
that test returns C<True> first.

=head2 method is-component-optional

    method is-component-optionaal(Str $component --> Bool)

This method will return C<True> if the component is optional, that is, it has
the "?" or "*" flags set on it.

=head2 method is-component-slurpy

    method is-component-slurpy(Str $component --> Bool)

This method will return C<True> if the component is slurpy, that is, it has the
"+" or "*" flags set on it.

=head2 method is-component-variable

    method is-component-variable(Str $component --> Bool)

This method will return C<True> if the component is a variable.

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
