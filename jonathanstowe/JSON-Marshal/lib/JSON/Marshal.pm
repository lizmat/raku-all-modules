use v6.c;

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

If you want to ignore any attributes without a value you can use the
:skip-null adverb to C<marshal>, which will supress the marshalling of
any undefined attributes.  Additionally if you want a finer-grained control
over this behaviour there is a 'json-skip-null' attribute trait which
will cause the specific attribute to be skipped if it isn't defined irrespective
of the C<skip-null>.

To allow a finer degree of control of how an attribute is marshalled an
attribute trait C<is marshalled-by> is provided, this can take either 
a Code object (an anonymous subroutine,) which should take as an argument
the value to be marshalled and should return a value that can be completely
represented as JSON, that is to say a string, number or boolean or a Hash
or Array who's values are those things. Alternatively the name of a method
that will be called on the value, the return value being constrained as
above.


=end pod

use JSON::Name;

module JSON::Marshal:ver<0.0.10>:auth<github:jonathanstowe> {

    use JSON::Fast:ver(v0.4..*);


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
            $value.defined ?? $value."$meth"() !! $type;
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

    role SkipNull {
    }

    multi sub trait_mod:<is> (Attribute $attr, :$json-skip-null!) is export {
        $attr does SkipNull;
    }
    
    multi sub _marshal(Cool $value, Bool :$skip-null) {
        $value;
    }

    multi sub _marshal(%obj, Bool :$skip-null) returns Hash {
        my %ret;

        for %obj.kv -> $key, $value {
            %ret{$key} = _marshal($value, :$skip-null);
        }

        %ret;
    }

    multi sub _marshal(@obj, Bool :$skip-null) returns Array {
        my @ret;

        for @obj -> $item {
            @ret.push(_marshal($item, :$skip-null));
        }
        @ret;
    }
    
    multi sub _marshal(Mu $obj, Bool :$skip-null) returns Hash {
        my %ret;
        for $obj.^attributes -> $attr {
            if $attr.has_accessor {
                my $name = do if $attr ~~ JSON::Name::NamedAttribute {
                    $attr.json-name;
                }
                else {
                    $attr.name.substr(2); # lose the sigil
                }
                my $value = $attr.get_value($obj);
                if serialise-ok($attr, $value, $skip-null) {
                    %ret{$name} = do if $attr ~~ CustomMarshaller {
                        $attr.marshal($value, $obj);
                    }
                    else {
                        _marshal($value);
                    }
                }

            }
        }
        %ret;
    }

    sub serialise-ok(Attribute $attr, $value, Bool $skip-null ) returns Bool {
        my $rc = True;
        if $skip-null || ( $attr ~~ SkipNull ) {
            if not $value.defined {
                $rc = False;
            }
        }
        $rc;
    }

    sub marshal(Any $obj, Bool :$skip-null) returns Str is export {
        my $ret = _marshal($obj, :$skip-null);
        to-json($ret);
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
