unit module AttrX::Lazy:ver<v0.0.1>:auth<github:pierre-vigier>;

my role LazyAttribute {
    has $.base-name = self.name.substr(2);
    has $.builder is rw = "build_"~self.base-name;
}

my class X::Usage is Exception {
    has Str $.message is rw;
}

my role LazyAttributeContainerHOW {
    method compose(Mu \type) {
        for type.^attributes.grep(LazyAttribute) -> $attr {
            if $attr.base-name ~~ type.^method_table {
                X::Usage.new(
                    message =>"A method '{$attr.base-name}' already exists, can't create lazy accessor \$.{$attr.base-name}'"
                ).throw();
            }
            for type.^roles_to_compose -> $r {
                if $attr.base-name ~~ $r.new.^method_table {
                    X::Usage.new(
                        message =>"A method '{$attr.base-name}' is provided by role '{$r.WHAT.^name}', can't create lazy accessor '\$.{$attr.base-name}'"
                    ).throw();
                }
            }
            unless $attr.builder ~~ type.^private_method_table {
                X::Usage.new(
                    message =>"No builder private method '{$attr.builder}' found, can't create lazy accessor \$.{$attr.base-name}'"
                ).throw();
            }

            type.^add_method($attr.base-name, method (Mu:D:) {
                  my $val = $attr.get_value( self );
                  unless $val.defined {
                      $val = self.^private_method_table{$attr.builder}( self );
                      $attr.set_value( self, $val );
                  }
                  return $val;
            });
        }
        callsame;
    }
}

multi trait_mod:<is>(Attribute:D $attr, :$lazy! ) is export {
    my $class := $attr.package;
    $attr does LazyAttribute;
    $attr.builder = $lazy.value if $lazy.key eq 'builder';

    unless $class.HOW ~~ LazyAttributeContainerHOW {
        $class.HOW does LazyAttributeContainerHOW
    }
}

=begin pod
=head1 NAME

AttrX::Lazy

=head1 SYNOPSIS

Provide a functionality similar to lazy in perl 5 with Moo

=head1 DESCRIPTION

This module provides trait lazy.
That trait will create a public accessor if attribute is private
or replace the accessor if the attribute is public.
A lazy attribute is read-onlu

Lazy attribute with call a builder the first time to calculate the
value of an attribute if not defined, and store the value.
It's especially useful for property of a class that take a long time
to compute, as they will be evaluated only on demand, and only once.

An alternate way of doing a similat functionality would be to just
create a public method with is cached trait, however, using lazy
allow to give a value within the constructor, and never do the
computation in that case

    use AttrX::Lazy;

    class Sample
        has $.attribute is lazy;

        method !build_attribute() {
            #heavy calculation
            return $value;
        }
    }

is equivalent to

    class Sample
        has $.attribute;

        method attribute() {
            unless $!attribute.defined {
                #heavy calculation
                $!attribute = $value;
            }
            $!attribute;
        }
    }

The builder method name can be changed like the following:

    use AttrX::Lazy;

    class Sample
        has $.attribute is lazy( builder => 'my_custom_builder' );

        method !my_custom_builder() {
            #heavy calculation
            return $value;
        }
    }

=head1 NOTES

Another approach to the same probleme here: https://github.com/jonathanstowe/Attribute-Lazy

Hopefully, lazyness of attribute at one point will be integrated in perl6 core, and
AttrX::Lazy will become useless

=head1 MISC

To test the meta data of the modules, set environement variable PERL6_TEST_META to 1

=end pod

