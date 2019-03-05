use v6;

=begin pod

=head1 NAME

JSON::Name - Provide a trait (and Attribute role) for JSON Marshal/Unmarshal where the JSON names aren't Perl identifiers

=head1 SYNOPSIS

=begin code

use JSON::Name;

class MyClass {
   # The attribute meta object will have the role JSON::Name::NamedAttribute
   # applied and "666.evil.name" will be stored in it's json-name attribute
   has $.nice-name is json-name('666.evil.name');

}

=end code

=head1 DESCRIPTION

This is released as a dependency of
L<JSON::Marshal|https://github.com/jonathanstowe/JSON-Marshal> and
L<JSON::Unmarshal|https://github.com/tadzik/JSON-Unmarshal> in order to
save duplication, it is intended to store a separate JSON name for an
attribute where the name of the JSON attribute might be changed, either
for aesthetic reasons or the name is not a valid Perl identifier. It will
of course also be needed in classes thar are going to use JSON::Marshal
or JSON::Unmarshal for serialisation/de-serialisation.

Of course it could be used in other modules for a similar purpose.

=end pod



module JSON::Name:ver<0.0.4>:auth<github:jonathanstowe> {
    role NamedAttribute {
        has Str $.json-name is rw;
    }

    multi sub trait_mod:<is>(Attribute $a, Str :$json-name!) is export(:DEFAULT){
        $a does NamedAttribute;
        $a.json-name = $json-name;
    }

}
# vim: expandtab shiftwidth=4 ft=perl6
