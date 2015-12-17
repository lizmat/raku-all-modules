#!perl6

use v6;

=begin pod

=head1 NAME

AccessorFacade -  turn indivdual get/set subroutines into a single read/write object attribute.

=head1 SYNOPSIS

=begin code

    use AccessorFacade;
    use NativeCall;

    class Shout is repr('CPointer') {

        sub shout_set_host(Shout, Str) returns int32 is native('libshout') { * } 
        sub shout_get_host(Shout) returns Str is native('libshout') { * }

        method host() is rw is attribute-facade(&shout_set_host, &shout_get_host) { }

        ...
    }

=end code

=head1 DESCRIPTION

This module was initially designed to reduce the boiler plate code in
a native library binding that became something like:

    class Shout is repr('CPointer') {

        sub shout_set_host(Shout, Str) returns int32 is native('libshout') { * }
        sub shout_get_host(Shout) returns Str is native('libshout') { * }

        method host() is rw {
            Proxy.new(
                FETCH => sub ($) {
                    shout_get_host(self);
                },
                STORE   =>  sub ($, $host is copy ) {
                    explicitly-manage($host);
                    shout_set_host(self, $host);
                }
            );
        }

        ...

    }

That is the library API provides a sort of "object oriented" mechanism to
set and get attributes on an opaque object instance that was returned
by another "constructor" function. Because the object is an opaque
CPointer it can only have subroutines and methods and not private data or
attributes. The intent of the code is to provide fake "attributes" with
rw methods (which is similar to how public rw attributes are provided.)

The above code will be reduced with the use of AccessorFacade to:

=begin code

    class Shout is repr('CPointer') {

        sub shout_set_host(Shout, Str) returns int32 is native('libshout') { * } 
        sub shout_get_host(Shout) returns Str is native('libshout') { * }

        method host() is rw is attribute-facade(&shout_set_host, &shout_get_host) { }

        ...
    }

=end code

(The call to explicitly manage is omitted for simplicity but how this is
achieved is described in the documentation.)  Libshout has a significant
number of these get/set pairs so there is a reduction of typing, copy
and paste and hopefully programmer error.

Whilst this was designed primarily to work with a fixed native API, it
is possible that it could be used to provide an OO facade to a plain
perl procedural library. The only requirement that there is a getter
subroutine that accepts an object as its first argument and returns the
attribute value and a setter subroutine that accepts the object and the
value to be set (it may return a value to indicate success - how this
is handled is descibed in the documentation.)

=head2 TRAIT APPLICATION

The trait C<attribute-facade> should be applied to an object method
with no arguments that has the C<rw> trait, (if the method isn't rw then
assignment simply won't work, no check is currently performed.)  The body
of the method should be empty, but will be discarded anyway if it isn't.

The signature of the trait can be thought of as being:

    attribute-facade(Method:D: $method, &getter, &setter, &before?, &after?)

The individual arguments are:

=head3 &getter

This is the function that is called to retrieve the attribute value.
It has exactly one argument which is the invocant of the method
(i.e. C<self>).  Its return value will be the value of the method
invocation.

=head3 &setter

This is the function that will be called to set the attribute value
(i.e. when it is assigned to.)  It will be called with two arguments:
the invocant (C<self>) and the value to set.  It may return a value
which will be passed to L<&after|#&amp;after> if it is defined.

=head3 &before

If this is defined this will be called when the value is being set with
the invocant and the value and its returned value will be passed to
L<&setter|#&amp;setter> instead of the original value, it is free to do
what it likes as long as the resulting value is acceptable to the &setter.

This is how the C<explicitly-manage> would be applied in the example above:

=begin code

    sub managed($, Str $str is copy ) {
        explicitly-manage($str);
        $str;
    }

    method host() is rw is attribute-facade(&shout_set_host, &shout_get_host, &managed) { }

=end code

It is of course free to perform a validation and throw an exception or
whatever may be appropriate.

=head3 &after

This will be called after L<&setter|#&amp;setter> with the invocant
and the return value of C<&setter>.  It is primarily intended where
the setter may return a value to indicate the success or otherwise of
setting the attribute and this should be turned into an exception:

=begin code

    sub check($, Int $rc ) {
        if $rc != OK {
            die "value was not set";
        }
    }

    method host() is rw is attribute-facade(&shout_set_host, &shout_get_host, Code, &check) { }

=end code

Note in the above example the C<Code> type if used as a placeholder
for the empty C<&before> (this is due to the way the "arguments" to the
trait are checked.)

=end pod


module AccessorFacade:ver<v0.0.4>:auth<github:jonathanstowe> {

    my role Provider[&get, &set, &before?, &after?] {
        method CALL-ME(*@args) is rw {
            my $self = @args[0];
            Proxy.new(
                        FETCH   => sub ($) {
                          my $val =  &get($self);

                          my $ret-type = self.signature.returns;
                          # cheers hoelzro
                          if not $ret-type =:= Mu {
                              if $val !~~ $ret-type {
                                  try {
                                      $val = $ret-type($val);
                                  }
                              }
                          }
                          $val;
                        },
                        STORE   =>  sub ($, $val is copy ) {
                            my $store-val;
                            if &before.defined {
                                $store-val = &before($self, $val);
                            }
                            else {
                                # This is necessary because can()
                                # fails on an Enum RT#125445
                                try {
                                    $store-val = $val.value;
                                    CATCH {
                                        default {
                                            $store-val = $val;
                                        }
                                    }
                                }
                            }
                            my $rc = &set($self, $store-val);
                            if &after.defined {
                                &after($self, $rc);
                            }
                        }
            );
	    }
    }

    class X::AccessorFacade::Usage is Exception {
        has Str $.message is rw;
    }

    multi trait_mod:<is>(Method $r, :$accessor_facade!) is export {
        DEPRECATED('accessor-facade',|<0.0.2 0.0.3>);
        try {
            accessor-facade($r, $accessor_facade);
            CATCH {
                when X::TypeCheck::Binding {
                    die X::AccessorFacade::Usage.new(message => "trait 'accessor-facade' requires &getter and &setter arguments");
                }
            }
        }
    }
    multi trait_mod:<is>(Method $r, :$accessor-facade!) is export {
        try {
            accessor-facade($r, $accessor-facade);
            CATCH {
                when X::TypeCheck::Binding {
                    die X::AccessorFacade::Usage.new(message => "trait 'accessor-facade' requires &getter and &setter arguments");
                }
            }
        }
    }

    my sub accessor-facade(Method $r, List $accessor_facade) {
        if $accessor_facade.elems < 2 {
            die X::AccessorFacade::Usage.new(message => "trait 'accessor-facade' requires &getter and &setter arguments");

        }
        if not all($accessor_facade.list) ~~ Callable {
            die X::AccessorFacade::Usage.new(message => "trait 'accessor-facade' only takes Callable arguments");
        }

        my $before = $accessor_facade[2]:exists ?? $accessor_facade[2] !! Code;
        my $after  = $accessor_facade[3]:exists ?? $accessor_facade[3] !! Code;

	    $r does Provider[$accessor_facade[0], $accessor_facade[1], $before, $after];
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
