use v6;

unit module Smack:ver<0.2.0>:auth<github:zostay>;

=begin pod

=head1 NAME

Smack - Reference implementation of the Web API for Perl 6

=head1 DESCRIPTION

This aims to be the reference implementation of the P6W standard. The aims of
this project include:

=item Providing an example implementation of P6W to aid the development of other
servers.

=item Provide a set of tools and utilities to aid in the building of applications
and middleware.

=item Provide a testing ground for future extensions and modifications to P6W.

=item Provide a testing ground for determining how difficult P6W is to implement
at all layers of development.

=head1 STATUS

The current status of this code is VERY ALPHA. The P6W specification is still
wet on the paper and this implementation is not really even complete yet. The
standalone server works and is generally compatible with the 0.4.Draft of P6W
(as of this writing, I have just started on 0.5.Draft which this server does not
yet support). There is practically no documentation at this point.

At this point, I am in the process of porting the features of Plack to Smack as
a way of testing whether or not the P6W specification is feasible. The goal is
to make sure that the easy things are easy and the hard things are possible.

=head1 FAQ

=head2 How does this differ from Crust?

(This information may be dated. I haven't checked up on it recently.)

The Perl 6 L<Crust|https://github.com/tokuhirom/p6-Crust> project is a port of
the older L<PSGI
specification|https://metacpan.org/pod/release/MIYAGAWA/PSGI-1.102/PSGI.pod>
for Perl 5. The PSGI specification is a basically serial specification
implemented around HTTP/1.0 and parts of HTTP/1.1. This has several weaknesses
when it comes to supporting modern protocols, dealing with high-performance
applications, and application portability.

P6WAPI aims to be a forward looking specification that incorporates built-in
support for HTTP/2, WebSockets, and other concurrent and/or asynchronous
web-related protocols. It also aims to better support high-performance
applications and address the portability weaknesses in PSGI. Smack aims to be
the reference implementation for L<P6WAPI|https://github.com/zostay/P6WAPI>
instead.

=head2 How does this differ from Cro?

Cro provides a very different API for writing asynchronous web applications.  It
aims to produce applications, for the web or otherwise, that are built around
the concept of pipelines that transform input into output.  These are built
according to the specific API provided by Cro.

Smack (through the specification in P6WAPI) provides something similar, but
instead of thinking of an application as a pipeline that transforms inputs into
outputs, it treats the application as an asynchronous subroutine. Pipelining is
performed by wrapping that subroutine in another subroutine rather than creating
another transformer class as is done in Cro.

P6WAPI could be implemented as a transformer in Cro or Cro could be made to run
within a Smack web server, but they are fundamentally different ways of thinking
about a similar problem each with their own trade-offs.

=head2 Can I participate?

PATCHES WELCOME!! Please help!

If you have any interest in participating in the development of this project,
please have a look. There is precious little documentation as things are still
changing a little too quickly in P6WAPI as yet. If you need help please shoot me
an email, file an issue, or ping me on IRC. Please note that I am lurking as
zostay on irc.perl.org and Freenode, but it is unusual that I am actually
looking at my chat window, so email is your best bet (see below for my email).

=head2 How do I get started?

=item Install perl6 (For example, on Mac OSX, C<brew install rakudo-star>
(rakudo is a compiler for Perl 6.  That command will put the `perl6` executable
in your path.  See L<http://perl6.org/> for more details or how
to install on other platforms).

=item Clone this repository (e.g. C<git clone https://github.com/zostay/Smack.git>)

=item Go into the Smack directory and run C<zef install . --deps-only>

=item Run C<perl6 t/env.t> to run a few tests and see if things are working at a
basic level

=item If that looks good, a simple C<Hello World> example is provided in
C<examples/hello-world.p6w>:

=begin code
#!smackup
# vim: set ft=perl6 :

use v6;

sub app(%env) {
    start {
        200, [ Content-Type => 'text/plain' ], 'Hello, World!';
    }
}
=end code

=item until you have everything in your path, you can start the application
with C<perl6 -I lib/ bin/smackup --app=examples/hello-world.p6w>

=item that command should show you some debugging output, like this:

    Starting on http://0.0.0.0:5000/...

=item You should now be able to open a browser and put C<http://0.0.0.0:5000/>
in the location bar, and see a message familiar to programmers world
wide.

=item There are other examples in the t/apps directory that you can look
at to start to get an idea of how it works.

=head1 CONTRIBUTORS

Sterling Hanenkamp C<< <hanenkamp@cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2019 Andrew Sterling Hanenkamp.

This is free software made available under the Artistic 2.0 license.

=end pod
