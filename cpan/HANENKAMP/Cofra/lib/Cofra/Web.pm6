use v6;

use Cofra::App::Godly;
use Cofra::WebObject;

unit class Cofra::Web does Cofra::WebObject does Cofra::App::Godly;

use Cofra::Logger;
use Cofra::Web::Controller;
use Cofra::Web::Controller::Error;
use Cofra::Web::Match;
use Cofra::Web::Request;
use Cofra::Web::Request::Match;
use Cofra::Web::Response;
use Cofra::Web::Router;
use Cofra::Web::View;
use X::Cofra::Web::Error;

has Cofra::Web::Controller %.controllers;
has Cofra::Web::View %.views;
has Cofra::Web::Router $.router;
has Cofra::Web::Controller $.error-controller = Cofra::Web::Controller::Error.new;

method access-controller { $.app.access-controller }

method log-critical(|c) { $.logger.log-critical(|c) }
method log-error(|c) { $.logger.log-error(|c) }
method log-warn(|c) { $.logger.log-warn(|c) }
method log-info(|c) { $.logger.log-info(|c) }
method log-debug(|c) { $.logger.log-debug(|c) }

method check-access(Cofra::Web::Request:D $req --> Bool:D) {
    # TODO Figure out how this should be implemented.
    return True without $.access-controller;

    !!!
}

method controller(Str:D $name) {
    %!controllers{ $name } // die "no controller named $name";
}

multi method target(&target --> Callable:D) { &target }

multi method target(Str:D :$controller, Str:D :$action, |args --> Callable:D) {
    self.target($controller, $action, |args);
}

multi method target(Str:D $controller-name, Str:D $action, |args --> Callable:D) {
    my $c = self.controller($controller-name);
    sub (Cofra::Web::Request:D $r --> Cofra::Web::Response:D) {
        $c.fire($action, $r, |args);
    }
}

method view(Str:D $name, Cofra::Web::Request:D $request --> Cofra::Web::View::Instance:D) {
    my $view = %!views{ $name } // die "no view named $name";
    $view.activate($request);
}

method request-response-dispatch(Cofra::Web::Request:D $req --> Cofra::Web::Response:D) {
    my Cofra::Web::Match $match = self.router.match($req);

    return self.error-controller.fire('not-found', $req) without $match;

    my $match-req = $req but Cofra::Web::Request::Match[$match];

    return self.error-controller.fire('forbidden', $match-req)
        unless self.check-access($match-req);

    $match-req.target.($match-req);
}

=begin pod

=head1 NAME

Cofra::Web - web application God object

=head1 SYNOPSIS

    use Cofra::Web;

    unit class MyApp::Web is Cofra::Web;

=head1 DESCRIPTION

This is a master application God-object specialized for web applications. It provides the crossroads for finding your ACL system for security, controller objects for mapping endpoints to business logic inputs, view objects for mapping business logic outputs to formatting tools, routing systems for declaring which endpoints exist, etc.

=head1 METHODS

=head2 method controllers

    has Cofra::Web::Controller %.controllers;

This is a map of all the controller objects associated with this web application.

=head2 method views

    has Cofra::Web::View %.views;

This is a map of all the view objects associated with this web application.

=head2 method router

    has Cofra::Web::Router $.router;

This is a reference to the router object for this web application.

=head2 method error-controller

    has Cofra::Web::Controller $.error-controller;

This is a reference to the special error controller for this web application.

=head2 method log-critical

    method log-critical(*@msg)

Pass through to the logger.

=head2 method log-error

    method log-error(*@msg)

Pass through to the logger.

=head2 method log-warn

    method log-warn(*@msg)

Pass through to the logger.

=head2 method log-info

    method log-info(*@msg)

Pass through to the logger.

=head2 method log-debug

    method log-debug(*@msg)

Pass through to the logger.

=head2 method check-access

    method check-access(Cofra::Web::Request:D $req --> Bool:D)

Not yet implemented.

=head2 method controller

    method controller(Str:D $name --> Cofra::Web::Controller:D)

Returns the controller for the given name or dies if no such controller with the given C<$name> is present.

=head2 method target

    multi method target(&target --> Callable:D)
    multi method target(Str:D :$controller!, Str:D :$action!, |args -> Callable:D) {
    multi method target(Str:D $controller, Str:D $action, |args --> Callable:D)

This is a helper used to build a callable that will execute the given C<$action> on the named C<$controller> object.

=head2 method view

    method view(Str:D $name, Cofra::Web::Request:D $request --> Cofra::Web::View::Instance:D)

Given the C<$name> of a view and a C<$request> to build the response from, this returns an instance of the named view that will render output for that type of view.

=head2 method request-response-dispatch

    method request-response-dispatch(Cofra::Web::Request:D $request --> Cofra::Web::Response:D)

This is a generic handler for standard synchronous web request-response dispatch cycles.

=end pod
