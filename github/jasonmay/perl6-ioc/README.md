[![Build Status](https://travis-ci.org/ufobat/perl6-ioc.svg?branch=master)](https://travis-ci.org/ufobat/perl6-ioc)

NAME
====

IoC - Wire your application components together using inversion of control

SYNOPSIS
========

    use IoC;

    my $c = container 'myapp' => contains {

        service 'logfile' => 'logfile.txt';

        service 'logger' => {
            'class'        => 'MyLogger',
            'lifecycle'    => 'Singleton',
            'dependencies' => {'logfile' => 'logfile'},
        };

        service 'storage' => {
            'lifecycle' => 'Singleton',
            'block'     => sub {
                ...
                return MyStorage.new();
            },
        };

        service 'app' => {
            'class'        => 'MyApp',
            'lifecycle'    => 'Signleton',
            'dependencies' => {
                'logger'  => 'logger',
                'storage' => 'storage',
            },
        };

    };

    my $app = $c.resolve(service => 'app');
    $app.run();

DESCRIPTION
===========

IoC is a port of stevan++'s Perl 5 module Bread::Board.

INVERSION OF CONTROL
====================

Inversion of control is a way of keeping all your component creation logic in one place. Instead of creating an object and explicitly pass it around everywhere, one could just make a *container* of all these components and allow the components to cleanly interact with each other as *services*.

EXPORTED FUNCTIONS
==================

  * **container**

Creates a new [IoC::Container](IoC::Container) object. In the block you create your services.

  * **service**

Adds services to your container, bringing your components together. See `IoC::Service` for more information on this.

BUGS
====

All complex software has bugs lurking in it, and this module is no exception. If you find a bug please either email me, or post an issue to http://github.com/jasonmay/perl6-ioc/

REFERENCE
=========

  * [IoC::Container](IoC::Container) - Container of all your application components

  * [IoC::Service](IoC::Service) - Service representing a component in your application

ACKNOWLEDGEMENTS
================

  * Thanks to Stevan Little who is the original author of Perl 5's Bread::Board

AUTHOR
======

Jason May, <jason.a.may@gmail.com>

LICENSE
=======

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

