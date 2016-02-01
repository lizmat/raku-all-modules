use v6;

=begin pod

=head1 NAME

Attribute::Lazy - lazy attribute initialisation

=head1 SYNOPSIS

=begin code

use Attribute::Lazy;

class Foo {
    has $.foo will lazy { "zub" };
    has $.booble will lazy { $_.bungle };
    method bungle() {
        'beep';
    }

}

=end code

=head1 DESCRIPTION

This is based on an experimental trait that was briefly in the Rakudo core.

Attribute::Lazy provides a single C<trait> C<will lazy> that will allow
an attribute with a public accessor (that is one defined with the C<.> twigil,)
to be initialised I<the first time it is accessed> by the result of the supplied
block.  This might be useful if the value may not be used and may be expensive
to calculate (or various other reasons that haven't been thought of.)

The supplied block will have the object instance passed to it as an argument,
which can be used to call other methods or public accessors on the object, you
probably want to avoid calling anything that may depend on the value of the
attribute for obvious reasons.

=end pod

module Attribute::Lazy {

    my role Builder[Callable $block] {
            method compose(Mu $package) {
                callsame;
                my $attr = self;
                if $attr.has_accessor {
                    my $meth-name = self.name.substr(2);
                    $package.^method_table{$meth-name}.wrap(-> $self {
                        if not $attr.get_value($self).defined {
                            $attr.set_value($self, $block($self));
                        }
                        callsame;
                    });
                }
            }

    }

    multi sub trait_mod:<will>(Attribute:D $attr, Callable $block, :$lazy!) is export(:DEFAULT) {
        $attr does Builder[$block];
    }

}


# vim: expandtab shiftwidth=4 ft=perl6
