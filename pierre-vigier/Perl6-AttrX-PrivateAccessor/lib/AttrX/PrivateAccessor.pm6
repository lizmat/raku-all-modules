unit module AttrX::PrivateAccessor:ver<v0.0.1>:auth<github:pierre-vigier>;

multi trait_mod:<is>(Attribute:D $attr, :$providing-private-accessor! ) is export {
    my $class = $attr.package;
    my $name = $attr.name.substr(2); #drop the initial $!
    if $name ~~ $class.^private_method_table {
        die "A private method with attribute name already exists, can't create private accessor";
    } else {
        $class.^add_private_method($name, method (Mu:D:) {
            $attr.get_value( self );
        });
    }
}

=begin pod
=head1 NAME

AttrX::PrivateAccessor

=head1 SYNOPSIS

Provide private accessor for private attribute

=head1 DESCRIPTION

This module provides trait providing-private-accessor, which will create a private accessor for a private attribute
It allows from within a class to access another instance of the same class' private attributes

    use AttrX::PrivateAccessor;

    class Sampl
        has $!attribute is providing-private-accessor;
    }

is equivalent to

    class Sampl
        has $!attribute;

        !method attribute() {
            return $!attribute;
        }
    }

=head1 MISC

To test the meta data of the modules, set environement variable PERL6_TEST_META to 1

=end pod
