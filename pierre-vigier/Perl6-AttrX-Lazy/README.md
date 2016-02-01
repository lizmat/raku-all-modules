# Perl6-AttrX::Lazy

[![Build Status](https://travis-ci.org/pierre-vigier/Perl6-AttrX-Lazy.svg?branch=master)](https://travis-ci.org/pierre-vigier/Perl6-AttrX-Lazy)

NAME
====

AttrX::Lazy

SYNOPSIS
========

Provide a functionality similar to lazy in perl 5 with Moo

DESCRIPTION
===========

This module provides trait lazy. That trait will create a public accessor if attribute is private or replace the accessor if the attribute is public. A lazy attribute is read-onlu

Lazy attribute with call a builder the first time to calculate the value of an attribute if not defined, and store the value. It's especially useful for property of a class that take a long time to compute, as they will be evaluated only on demand, and only once.

An alternate way of doing a similat functionality would be to just create a public method with is cached trait, however, using lazy allow to give a value within the constructor, and never do the computation in that case

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

NOTES
=====

Another approach to the same probleme here: https://github.com/jonathanstowe/Attribute-Lazy

Hopefully, lazyness of attribute at one point will be integrated in perl6 core, and AttrX::Lazy will become useless

MISC
====

To test the meta data of the modules, set environement variable PERL6_TEST_META to 1
