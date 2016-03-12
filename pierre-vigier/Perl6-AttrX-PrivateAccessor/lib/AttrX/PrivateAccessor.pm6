unit module AttrX::PrivateAccessor:ver<v0.0.2>:auth<github:pierre-vigier>;

my role PrivateAccessor {
    has $.private-accessor-name is rw = self.name.substr(2);
}

my class X::Usage is Exception {
    has Str $.message is rw;
}

my role PrivateAccessorContainerHOW {
    method compose(Mu \type) {
        for type.^attributes.grep(PrivateAccessor) -> $attr {
            if $attr.private-accessor-name ~~ type.^private_method_table {
                X::Usage.new(
                    message =>"A private method '{$attr.private-accessor-name}' already exists, can't create private accessor for accessot '\$!{$attr.private-accessor-name}'"
                ).throw();
            }
            for type.^roles_to_compose -> $r {
                if $attr.private-accessor-name ~~ $r.new.^private_method_table {
                    X::Usage.new(
                        message =>"A private method '{$attr.private-accessor-name}' is provided by role '{$r.WHAT.^name}', can't create private accessor for accessot '\$!{$attr.private-accessor-name}'"
                    ).throw();
                }
            }

            type.^add_private_method($attr.private-accessor-name, method (Mu:D:) {
                  $attr.get_value( self );
            });
        }
        callsame;
    }
}

multi trait_mod:<is>(Attribute:D $attr, :$private-accessible! ) is export {
    my $class := $attr.package;
    $attr does PrivateAccessor;
    $attr.private-accessor-name = $private-accessible
        if $private-accessible ~~ Str;
    unless $class.HOW ~~ PrivateAccessorContainerHOW {
        $class.HOW does PrivateAccessorContainerHOW
    }
}


=begin pod
=head1 NAME

AttrX::PrivateAccessor

=head1 SYNOPSIS

Provide private accessor for private attribute, provide only read accessor, see NOTES for the reason

=head1 DESCRIPTION

This module provides trait private-accessible (providing-private-accessor was too long), which will
create a private accessor for a private attribute, in read only, no modification possible

It allows from within a class to access another instance of the same class' private attributes

    use AttrX::PrivateAccessor;

    class Sample
        has $!attribute is private-accessible;
    }

is equivalent to

    class Sample
        has $!attribute;

        method !attribute() {
            return $!attribute;
        }
    }

The private accessor method by default will have the name of the attribute, but
can be customized, as an argument to the trait

    use AttrX::PrivateAccessor;

    class Sample
        has $!attribute is private-accessible('accessor');
    }

THe private method will then be

    method !accessor() { $!attribute }

A use case for having private read accessor could be, let's see that we have class
who store a chareacteristic under an interanl format, that should not be visible from
the outside.
To check if two instances of that class are equal, we have to compare that internal
value, we would have a method like that

    class Foo {
        has $!characteristic is private-accessible;

        ...

        method equal( Foo:D: Foo:D $other ) {
            return $!characteristic == $other!characteristic;
        }
    }

Without the trai, we can't know the value in the other instance

=head1 NOTES

This module create private accessor in read-only mode. Even if really useful sometimes,
accessing private attributes of another instance of the same class is starting to violate
encapsulation. Giving permission to modify private attributes of another instance seemed a
bit to much, if it is really needed, i guess it would really be some specific case, where
writing a dedicated private method with comments seems more adequate.
However, if one day that behavior has to be implemented, it could be done through a
parameter of the trait, like

    has $!attribute is private-accessible( :rw )

=head1 MISC

To test the meta data of the modules, set environement variable PERL6_TEST_META to 1

=end pod
