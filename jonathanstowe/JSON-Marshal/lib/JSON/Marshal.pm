use v6;

=begin pod

=head1 NAME

JSON::Marshal - Make JSON from an Object.

=head1 SYNOPSIS

=begin code
    use JSON::Marshal;

    class SomeClass {
      has Str $.string;
      has Int $.int;
      has Version $.version is marshalled-by('Str');
    }

    my $object = SomeClass.new(string => "string", int => 42, version => Version.new("0.0.1"));


    my Str $json = marshal($object); # -> "{ "string" : "string", "int" : 42, "version" : "0.0.1" }'

=end code

=head1 DESCRIPTION

This provides a single exported subroutine to create a JSON representation
of an object.  It should round trip back into an object of the same class
using L<JSON::Unmarshal|https://github.com/tadzik/JSON-Unmarshal>.

It only outputs the "public" attributes (that is those with accessors
created by declaring them with the '.' twigil. Attributes without acccessors
are ignored.

To allow a finer degree of control of how an attribute is marshalled an
attribute trait C<is marshalled-by> is provided, this can take either 
a Code object (an anonymous subroutine,) which should take as an argument
the value to be marshalled and should return a value that can be completely
represented as JSON, that is to say a string, number or boolean or a Hash
or Array who's values are those things. Alternatively the name of a method
that will be called on the value, the return value being constrained as
above.


=end pod

module JSON::Marshal:ver<v0.0.3>:auth<github:jonathanstowe> {

    use JSON::Tiny;
    use JSON::Name;


    role CustomMarshaller {
        method marshal($value, Mu:D $object) {
            ...
        }
    }

    role CustomMarshallerCode does CustomMarshaller {
        has &.marshaller is rw;

        method marshal($value, Mu:D $object) {
            # the dot below is important otherwise it refers
            # to the accessor method
            self.marshaller.($value);
        }
    }

    role CustomMarshallerMethod does CustomMarshaller {
        has Str $.marshaller is rw;
        method marshal($value, Mu:D $type) {
            my $meth = self.marshaller;
            $value."$meth"();
        }
    }

    multi sub trait_mod:<is> (Attribute $attr, :&marshalled-by!) is export {
        $attr does CustomMarshallerCode;
        $attr.marshaller = &marshalled-by;
    }

    multi sub trait_mod:<is> (Attribute $attr, Str:D :$marshalled-by!) is export {
        $attr does CustomMarshallerMethod;
        $attr.marshaller = $marshalled-by;
    }
    
    multi sub _marshal(Cool $value) {
        $value;
    }

    multi sub _marshal(%obj) returns Hash {
        my %ret;

        for %obj.kv -> $key, $value {
            %ret{$key} = _marshal($value);
        }

        %ret;
    }

    multi sub _marshal(@obj) returns Array {
        my @ret;

        for @obj -> $item {
            @ret.push(_marshal($item));
        }
        @ret;
    }
    
    multi sub _marshal(Mu $obj) returns Hash {
        my %ret;
        for $obj.^attributes -> $attr {
            if $attr.has-accessor {
                my $name = do if $attr ~~ JSON::Name::NamedAttribute {
                    $attr.json-name;
                }
                else {
                    $attr.name.substr(2); # lose the sigil
                }
                my $value = $attr.get_value($obj);
                %ret{$name} = do if $attr ~~ CustomMarshaller {
                    $attr.marshal($value, $obj);
                }
                else {
                    _marshal($value);
                }

            }
        }
        %ret;
    }

    sub marshal(Any $obj) returns Str is export {
        my $ret = _marshal($obj);
        to-json($ret);
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
