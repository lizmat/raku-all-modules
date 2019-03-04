use v6;

use Cofra::Context;

unit role Cofra::Web::Request does Cofra::Context;

use Cofra::Web::Response;

# TODO Decide what request methods are always standard here

method router-context(--> Hash:D) { %() }

method start-response(--> Cofra::Web::Response:D) { ... }

=begin pod

=head1 NAME

Cofra::Web::Request - the web request interface

=head1 DESCRIPTION

This defines the interface for request handling. It acts as drill instructor to
all those unruly kids who think they can do web requests their own way. Well
they can't. And their mommies aren't here to help them anymore.

=head1 METHODS

=head2 method router-context

   method router-context(--> Hash:D)

I don't know what this does yet. Well, I know what it does NOW but I'm not making any promises. For the moment it provides the magic communication between the request and the router object to allow the router to make decisions about routing that is not based on the path (such as routing based on request method). However, it's an open question as to whether this will continue. I need to document its existence because it's important, I don't really want to make any promises about its future.

=head2 method start-response

    method start-response(--> Cofra::Web::Response:D)

The request and response objects must be compatible with whatever the external
interface of the web server is. As such, the request and response objects need
to be paired to that server infrastructure using adapters. For the given
request, this will construct an appropriately paired response.

=head1 CAVEATS

Ths actually does not declare much of that interface as of this writing. It's
mostly empty, but one day it will mandate that the methods defined elsewhere be
defined for anything wanting to act as a request object.

=end pod
