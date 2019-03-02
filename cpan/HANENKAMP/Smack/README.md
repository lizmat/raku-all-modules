NAME
====

Smack - Reference implementation of the Web API for Perl 6

DESCRIPTION
===========

This aims to be the reference implementation of the P6W standard. The aims of this project include:

  * Providing an example implementation of P6W to aid the development of other servers.

  * Provide a set of tools and utilities to aid in the building of applications and middleware.

  * Provide a testing ground for future extensions and modifications to P6W.

  * Provide a testing ground for determining how difficult P6W is to implement at all layers of development.

STATUS
======

The current status of this code is VERY ALPHA. The P6W specification is still wet on the paper and this implementation is not really even complete yet. The standalone server works and is generally compatible with the 0.4.Draft of P6W (as of this writing, I have just started on 0.5.Draft which this server does not yet support). There is practically no documentation at this point.

At this point, I am in the process of porting the features of Plack to Smack as a way of testing whether or not the P6W specification is feasible. The goal is to make sure that the easy things are easy and the hard things are possible.

FAQ
===

How does this differ from Crust?
--------------------------------

(This information may be dated. I haven't checked up on it recently.)

The Perl 6 [Crust](https://github.com/tokuhirom/p6-Crust) project is a port of the older [PSGI specification](https://metacpan.org/pod/release/MIYAGAWA/PSGI-1.102/PSGI.pod) for Perl 5. The PSGI specification is a basically serial specification implemented around HTTP/1.0 and parts of HTTP/1.1. This has several weaknesses when it comes to supporting modern protocols, dealing with high-performance applications, and application portability.

P6WAPI aims to be a forward looking specification that incorporates built-in support for HTTP/2, WebSockets, and other concurrent and/or asynchronous web-related protocols. It also aims to better support high-performance applications and address the portability weaknesses in PSGI. Smack aims to be the reference implementation for [P6WAPI](https://github.com/zostay/P6WAPI) instead.

How does this differ from Cro?
------------------------------

Cro provides a very different API for writing asynchronous web applications. It aims to produce applications, for the web or otherwise, that are built around the concept of pipelines that transform input into output. These are built according to the specific API provided by Cro.

Smack (through the specification in P6WAPI) provides something similar, but instead of thinking of an application as a pipeline that transforms inputs into outputs, it treats the application as an asynchronous subroutine. Pipelining is performed by wrapping that subroutine in another subroutine rather than creating another transformer class as is done in Cro.

P6WAPI could be implemented as a transformer in Cro or Cro could be made to run within a Smack web server, but they are fundamentally different ways of thinking about a similar problem each with their own trade-offs.

Can I participate?
------------------

PATCHES WELCOME!! Please help!

If you have any interest in participating in the development of this project, please have a look. There is precious little documentation as things are still changing a little too quickly in P6WAPI as yet. If you need help please shoot me an email, file an issue, or ping me on IRC. Please note that I am lurking as zostay on irc.perl.org and Freenode, but it is unusual that I am actually looking at my chat window, so email is your best bet (see below for my email).

How do I get started?
---------------------

  * Install perl6 (For example, on Mac OSX, `brew install rakudo-star` (rakudo is a compiler for Perl 6. That command will put the `perl6` executable in your path. See [http://perl6.org/](http://perl6.org/) for more details or how to install on other platforms).

  * Clone this repository (e.g. `git clone https://github.com/zostay/Smack.git`)

  * Go into the Smack directory and run `zef install . --deps-only`

  * Run `perl6 t/env.t` to run a few tests and see if things are working at a basic level

  * If that looks good, a simple `Hello World` example is provided in `examples/hello-world.p6w`:

    #!smackup
    # vim: set ft=perl6 :

    use v6;

    sub app(%env) {
        start {
            200, [ Content-Type => 'text/plain' ], 'Hello, World!';
        }
    }

  * until you have everything in your path, you can start the application with `perl6 -I lib/ bin/smackup --app=examples/hello-world.p6w`

  * that command should show you some debugging output, like this:

    Starting on http://0.0.0.0:5000/...

  * You should now be able to open a browser and put `http://0.0.0.0:5000/` in the location bar, and see a message familiar to programmers world wide.

  * There are other examples in the t/apps directory that you can look at to start to get an idea of how it works.

CONTRIBUTORS
============

Sterling Hanenkamp `<hanenkamp@cpan.org> `

LICENSE AND COPYRIGHT
=====================

Copyright 2019 Andrew Sterling Hanenkamp.

This is free software made available under the Artistic 2.0 license.

