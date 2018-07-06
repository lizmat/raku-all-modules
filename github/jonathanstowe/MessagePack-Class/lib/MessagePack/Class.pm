use v6.c;

=begin pod

=head1 NAME

MessagePack::Class - Serialize/Deserialize Perl 6 classes to/from MessagePack blobs

=head1 SYNOPSIS

=begin code

use MessagePack::Class;

class MyClass does MessagePack::Class {
	has Str $.some-data;
}

my Blob $pack = MyClass.new(some-data => "whatever").to-messagepack;

# Then send $pack over the network, write it to a file or something

my MyClass $obj = MyClass.from-messagepack($pack);


=end code

=head1 DESCRIPTION

L<MessagePack|http://msgpack.org/> is a binary serialization format that
is particularly efficient for transmission over a network or file storage.

This module provides a role that allows for the direct serialization of
a Perl 6 object to a MessagePack binary blob and the deserialization of
that blob back to a Perl 6 object of the same type with the same attribute
values.

Under the hood it uses L<Data::MessagePack|https://github.com/pierre-vigier/Perl6-Data-MessagePack>
to serialize and deserialize data structures representing the object in a very
similar manner to L<JSON::Marshal|https://github.com/jonathanstowe/JSON-Marshal> and
L<JSON::Unmarshal|https://github.com/tadzik/JSON-Unmarshal> (infact it borrows some
of the internal code of both of those to construct a suitable data structure.)

For a simple case this may work with your class unchanged apart from the addition of
the role composition, however for types that may not be properly constructed from
their public attributes there are provided the attribute traits C<packed-by> and
C<unpacked-by> which allow you to provide either a subroutine or a method name
that will work with a representation that will round-trip properly.

A named method supplied to C<packed-by> will be called on the object to be serialized
without any arguments and should return a value suitable for serialization, and a method
supplied to C<unpacked-by> will be called on the type object with the value to be
deserialized as a single positional argument and should return an object of the type.


So for instance if one had a class with an attribute of type Version one might do:

=begin code

class TraitTest does MessagePack::Class {
    has Version $.version is packed-by('Str') is unpacked-by('new');
}
=end code

Where the C<Str> method returns a string that is suitable to be passed to C<new>
to create a new Version  object.

If a subroutine (or other Callable object) is passed to the traits then it should take
a single argument and return a value suitable for serialization (for C<packed-by>) or
an object of the appropriate type (for C<unpacked-by>) so the above example might
become:

=begin code

class TraitTest does MessagePack::Class {
    has Version $.version is packed-by(-> Version $v { $v.Str }) is unpacked-by(-> Str $v { Version.new($v)});
}

=end code

You can of course make the subroutines as complex as is required for your types.

If you need your data to be interoperable with software written in another language
you may need to adjust the serialization accordingly to match the types available
in that language.

=head1 METHODS

=head2 method to-messagepack

This should be called on an object of the consuming class and will return a C<Blob>
containing the MessagePack data.

=head2 method from-messagepack

This should be called on the type object (i.e. a class method,) of the consuming
class with a C<Blob> containing the MessagePack data that represents an object
of this type, it returns a new initialised object.

=end pod

role MessagePack::Class {
    use Data::MessagePack;

    method from-messagepack(Blob $pack) {
        _unmarshal(Data::MessagePack::unpack($pack), self);
    }


    my role CustomUnmarshaller {
        method unmarshal($value, Mu:U $type) {
            ...
        }
    }

    my role CustomUnmarshallerCode does CustomUnmarshaller {
        has &.unmarshaller is rw;

        method unmarshal($value, Mu:U $type) {
            self.unmarshaller.($value);
        }
    }

    my role CustomUnmarshallerMethod does CustomUnmarshaller {
        has Str $.unmarshaller is rw;
        method unmarshal($value, Mu:U $type) {
            my $meth = self.unmarshaller;
            $type."$meth"($value);
        }
    }

    multi sub trait_mod:<is> (Attribute $attr, :&unpacked-by!) is export {
        $attr does CustomUnmarshallerCode;
        $attr.unmarshaller = &unpacked-by;
    }

    multi sub trait_mod:<is> (Attribute $attr, Str:D :$unpacked-by!) is export {
        $attr does CustomUnmarshallerMethod;
        $attr.unmarshaller = $unpacked-by;
    }

    sub panic($data, $type) {
        die "Cannot unmarshal {$data.perl} to type {$type.perl}"
    }

    multi _unmarshal(Any:U, Mu $type) {
        $type;
    }

    multi _unmarshal(Any:D $data, Int) {
        if $data ~~ Int {
            return Int($data)
        }
        panic($data, Int)
    }

    multi _unmarshal(Any:D $data, Rat) {
        CATCH {
            default {
                panic($data, Rat);
            }
        }
        return Rat($data);
    }

    multi _unmarshal(Any:D $data, Numeric) {
        if $data ~~ Numeric {
            return Num($data)
        }
        panic($data, Numeric)
    }

    multi _unmarshal($data, Str) {
        if $data ~~ Stringy {
            return Str($data)
        }
        else {
            Str;
        }
    }

    multi _unmarshal(Any:D $data, Bool) {
        CATCH {
            default {
                panic($data, Bool);
            }
        }
        return Bool($data);
    }

    multi _unmarshal(Any:D $data, Any $x) {
        my %args;
        my %local-attrs =  $x.^attributes(:local).map({ $_.name => $_.package });
        for $x.^attributes -> $attr {
            if %local-attrs{$attr.name}:exists && !(%local-attrs{$attr.name} === $attr.package ) {
                next;
            }
            my $data-name = $attr.name.substr(2);
            if $data{$data-name}:exists {
                %args{$data-name} := do if $attr ~~ CustomUnmarshaller {
                    $attr.unmarshal($data{$data-name}, $attr.type);
                }
                else {
                    _unmarshal($data{$data-name}, $attr.type);
                }
            }
        }
        return $x.new(|%args)
    }

    multi _unmarshal($data, @x) {
        my @ret;
        for $data.list -> $value {
            my $type = @x.of =:= Any ?? $value.WHAT !! @x.of;
            @ret.append(_unmarshal($value, $type));
        }
        return @ret;
    }

    multi _unmarshal($data, %x) {
        my %ret;
        for $data.kv -> $key, $value {
            my $type = %x.of =:= Any ?? $value.WHAT !! %x.of;
            %ret{$key} = _unmarshal($value, $type);
        }
        return %ret;
    }

    multi _unmarshal(Any:D $data, Mu) {
        return $data
    }

    method to-messagepack(--> Blob) {
        Data::MessagePack::pack(_marshal(self));
    }

    my role CustomMarshaller {
        method marshal($value, Mu:D $object) {
            ...
        }
    }

    my role CustomMarshallerCode does CustomMarshaller {
        has &.marshaller is rw;

        method marshal($value, Mu:D $object) {
            # the dot below is important otherwise it refers
            # to the accessor method
            self.marshaller.($value);
        }
    }

    my role CustomMarshallerMethod does CustomMarshaller {
        has Str $.marshaller is rw;
        method marshal($value, Mu:D $type) {
            my $meth = self.marshaller;
            $value.defined ?? $value."$meth"() !! $type;
        }
    }

    multi sub trait_mod:<is> (Attribute $attr, :&packed-by!) is export {
        $attr does CustomMarshallerCode;
        $attr.marshaller = &packed-by;
    }

    multi sub trait_mod:<is> (Attribute $attr, Str:D :$packed-by!) is export {
        $attr does CustomMarshallerMethod;
        $attr.marshaller = $packed-by;
    }

    my role SkipNull {
    }

    multi sub trait_mod:<is> (Attribute $attr, :$pack-skip-null!) is export {
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
        my %local-attrs =  $obj.^attributes(:local).map({ $_.name => $_.package });
        for $obj.^attributes -> $attr {
            if %local-attrs{$attr.name}:exists && !(%local-attrs{$attr.name} === $attr.package ) {
                next;
            }
            if $attr.has_accessor {
                my $name = $attr.name.substr(2);
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
}
# vim: expandtab shiftwidth=4 ft=perl6
