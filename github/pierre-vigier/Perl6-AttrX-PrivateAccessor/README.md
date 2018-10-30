# Perl6-AttrX::PrivateAccessor

[![Build Status](https://travis-ci.org/pierre-vigier/Perl6-AttrX-PrivateAccessor.svg?branch=master)](https://travis-ci.org/pierre-vigier/Perl6-AttrX-PrivateAccessor)

NAME
====

AttrX::PrivateAccessor

SYNOPSIS
========

Provide private accessor for private attribute, provide only read accessor, see NOTES for the reason

DESCRIPTION
===========

This module provides trait private-accessible (providing-private-accessor was too long), which will create a private accessor for a private attribute, in read only, no modification possible

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

The private accessor method by default will have the name of the attribute, but can be customized, as an argument to the trait

    use AttrX::PrivateAccessor;

    class Sample
        has $!attribute is private-accessible('accessor');
    }

THe private method will then be

    method !accessor() { $!attribute }

A use case for having private read accessor could be, let's see that we have class who store a chareacteristic under an interanl format, that should not be visible from the outside. To check if two instances of that class are equal, we have to compare that internal value, we would have a method like that

    class Foo {
        has $!characteristic is private-accessible;

        ...

        method equal( Foo:D: Foo:D $other ) {
            return $!characteristic == $other!characteristic;
        }
    }

Without the trai, we can't know the value in the other instance

NOTES
=====

This module create private accessor in read-only mode. Even if really useful sometimes, accessing private attributes of another instance of the same class is starting to violate encapsulation. Giving permission to modify private attributes of another instance seemed a bit to much, if it is really needed, i guess it would really be some specific case, where writing a dedicated private method with comments seems more adequate. However, if one day that behavior has to be implemented, it could be done through a parameter of the trait, like

    has $!attribute is private-accessible( :rw )

MISC
====

To test the meta data of the modules, set environement variable PERL6_TEST_META to 1
