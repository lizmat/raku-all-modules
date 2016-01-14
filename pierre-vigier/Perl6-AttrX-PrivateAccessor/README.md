# Perl6-AttrX::PrivateAccessor

[![Build Status](https://travis-ci.org/pierre-vigier/Perl6-AttrX-PrivateAccessor.svg?branch=master)](https://travis-ci.org/pierre-vigier/Perl6-AttrX-PrivateAccessor)

NAME
====

AttrX::PrivateAccessor

SYNOPSIS
========

Provide private accessor for private attribute

DESCRIPTION
===========

This module provides trait providing-private-accessor, which will create a private accessor for a private attribute It allows from within a class to access another instance of the same class' private attributes

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

MISC
====

To test the meta data of the modules, set environement variable PERL6_TEST_META to 1
