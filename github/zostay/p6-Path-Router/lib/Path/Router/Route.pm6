use v6;

=TITLE Path::Router::Route;

=SUBTITLE An object to represent a route

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
    has Str @.components = self!build-components(); # is no-clone
    has Int $.length = self!build-length; # is no-clone
    has Int $.length-without-optionals = self!build-length-without-optionals; # is no-clone
    has $.required-variable-component-names = self!build-required-variable-component-names; # is no-clone
    has $.optional-variable-component-names = self!build-optional-variable-component-names; # is no-clone
    has $.target;

    method copy-attrs returns Hash {
        return (
            path        => $!path,
            defaults    => %!defaults,
            validations => %!validations,
            target      => $!target,
        ).hash;
    }

    method has-defaults returns Bool {
        ?%!defaults.keys;
    }

    method has-validations returns Bool {
        ?%!validations.keys;
    }

    method new(*%args) {
        my $self = self.bless(|%args);

        $self!validate-configuration;

        return $self;
    }

    submethod !validate-configuration {
        return unless self.has-validations;

        my $components = set @!components.grep({ 
            self.is-component-variable($^comp) 
        }).map({ 
            self.get-component-name($^comp) 
        });

        for %!validations.keys -> $validation {
            if $validation ∉ $components {
                die X::Path::Router::BadRoute.new(:$validation, :$!path);
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

    method create-default-mapping {
        %!defaults
    }

    method has-validation-for(Str $name) {
        %!validations{$name} :exists
    }

    # component checking

    method is-component-optional(Str $component) {
        ?($component ~~ / ^ \? \: /);
    }

    method is-component-variable(Str $component) {
        ?($component ~~ / ^ \? ? \: /);
    }

    method get-component-name(Str $component) {
        $component ~~ / ^ \? ? \: $<name>=[ .* ] $$ /;
        ~$<name>;
    }

    method match(@parts is copy) returns Path::Router::Route::Match {
        return Path::Router::Route::Match unless (
            $!length-without-optionals <= @parts.elems <= $!length
        );

        my %mapping = self.create-default-mapping if self.has-defaults;

        my @orig-parts = @parts;

        for @!components -> $c {
            unless @parts {
                die "should never get here: " ~
                    "no @parts left, but more required components remain"
                        if ! self.is-component-optional($c);
                last;
            }
            my $part = @parts.shift;

            if (self.is-component-variable($c)) {
                my $name = self.get-component-name($c);
                if self.has-validation-for($name) {
                    my $smart-match := %!validations{$name};

                    # FIXME kludge
                    # Since coercion syntax Int(Cool) is no worky...
                    my $test-part = $part;
                    {
                        given $smart-match {
                            when Int { $test-part .= Int }
                            when Num { $test-part .= Num }
                            when Rat { $test-part .= Rat }
                        }

                        # Absorb coercion exceptions
                        CATCH { default { } }
                    }

                    # Work-around RT#127071
                    my $match = do given $smart-match {
                        when Regex { $test-part ~~ /$smart-match/ }
                        default    { $test-part ~~ $smart-match }
                    };

                    # Make sure a regex is a total match
                    if ($match ~~ Match) {
                        return Path::Router::Route::Match 
                            unless $match && $match eq $test-part;
                    }
                    else {
                        return Path::Router::Route::Match 
                            unless $match;
                    }

                    # store the coerced version
                    $part = $test-part;
                }
                %mapping{$name} = $part;
            }
            else {
                return Path::Router::Route::Match unless $c eq $part;
            }
        }

        return Path::Router::Route::Match.new(
            path    => @orig-parts.join('/'),
            route   => self,
            mapping => %mapping,
        );
    }

}

=begin pod

=begin DESCRIPTION

This object is created by L<Path::Router> when you call the
C<add-route> method. In general you won't ever create these objects
directly, they will be created for you and you may sometimes
introspect them.

=end DESCRIPTION

=head1 Attributes

=head2 has $.path

=head2 has $.target

=head2 has $.components>

=head2 has $.length

=head2 has %.defaults

=head2 has %.validations

=head1 Methods

=head2 method has-defaults

=head2 method has-validations

=head2 method has-validation-for

=head2 method create-default-mapping

=head2 method match

=head1 Component checks

=head2 method get-component-name

    method get-component-name(Str $component)

=item method is-component-optional

    method is-component-optionaal(Str $component)

=item method is-component-variable

    method is-component-variable(Str $component)

=head1 Length methods

=item method length-without-optionals

=for BUGS
All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

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
