use v6;

=begin pod

=head1 NAME

JSON::Class - Role to allow a class to unmarshall/marshall itself from JSON

=head1 SYNOPSIS

=begin code

    use JSON::Class;

    class Something does JSON::Class {

        has Str $.foo;

    }

    my Something $something = Something.from-json('{ "foo" : "stuff" }');

    ...

    my Str $json = $something.to-json(); # -> '{ "foo" : "stuff" }'


=end code

=head1 DESCRIPTION

This is a simple role that provides methods to instantiate a class from a
JSON string that (hopefully,) represents it, and to serialise an object of
the class to a JSON string.  The JSON created from an instance should
round trip to a new instance with the same values for the "public attributes".
"Private" attributes (that is ones without accessors,) will be ignored for
both serialisation and de-serialisation.  The exact behaviour depends on that
of L<JSON::Marshal|https://github.com/jonathanstowe/JSON-Marshal> and
L<JSON::Unmarshal|https://github.com/tadzik/JSON-Unmarshal> respectively.

The  L<JSON::Marshal|https://github.com/jonathanstowe/JSON-Marshal> and
L<JSON::Unmarshal|https://github.com/tadzik/JSON-Unmarshal> provide traits
for controlling the unmarshalling/marshalling of specific attributes. If these
are required for your application then you will need to use these modules
directly in your code for the time being.

=head1 METHODS

=head2 method from-json

    method from-json(Str $json) returns JSON::Class

Deserialises the provided JSON string, returning a new object, with the
public attributes initialised with the corresponding values in the JSON
structure.

If the JSON is not valid or the data cannot be coerced into the correct 
type for the target class then an exception may be thrown.

=head2 method to-json

    method to-json() returns Str

Serialises the public attributes of the object to a JSON string that
represents the object, this JSON can be fed to the L<from-json> of the
class to create a new object with matching (public) attributes.

=end pod


role JSON::Class:ver<v0.0.2>:auth<github:jonathanstowe> {

    use JSON::Unmarshal;
    use JSON::Marshal;

    method from-json(Str $json) returns JSON::Class {
        unmarshal($json, self);
    }

    method to-json() returns Str {
        marshal(self);
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
