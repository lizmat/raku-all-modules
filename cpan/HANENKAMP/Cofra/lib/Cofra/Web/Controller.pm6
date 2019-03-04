use v6;

use Cofra::Web::Godly;

unit class Cofra::Web::Controller does Cofra::Web::Godly;

use Cofra::Web::Request;
use Cofra::Web::Response;

role Action { }

multi method fire(Str:D $action, Cofra::Web::Request $request, |args --> Cofra::Web::Response) {
    my $method = self.^find_method($action);
    if $method ~~ Action {
        self."$action"($request, |args);
    }
    else {
        die X::Cofra::Web::Error::NotFound.new(
            :$.web, :$request,
            cause => qq[action method "$action" does not exist or is not marked as an action],
        );
    }
}

multi trait_mod:<is> (Method $m, :$action!) is export {
    $m does Action;
}

=begin pod

=head1 NAME

Cofra::Web::Controller - provide the glue that maps web endpoints to business logic

=head1 SYNOPSIS

    use Cofra::Web::Controller;

    unit class MyApp::Web::Controller::So-And-So is Cofra::Web::Controller;

    method do-the-thing(Cofra::Web::Request:D $request --> Cofra::Web::Response:D $response) is action {
        ...
    }

=head1 DESCRIPTION

Action methods on the controller will be L<fired|#method fire> (as in shot from a canon, not
divorced from an organization) when a user visits an endpoint. The controller is
expected to do whatever is needed to prepare the request, call business logic,
and then craft a response—through the help of a view because we are not
animals!

=head1 METHODS

=head2 method fire

    method fire(Str:D $action, Cofra::Web::Request $request, |args --> Cofra::Web::Response)

Finds an appropriate action method, calls the method, and returns the result.
This method can only find methods flagged with the L<is action|#is action>
trait.

=head2 is action

    multi trait_mod:<is> (Method $m, :$action!) is export

Marks a method as being a public action. This should only be attached to method
that should be directly accessible to the public.

Methods with this marker is where you perform all the really precise input
validation and output encoding to make sure your web application is secure.
Right? RIGHT!? You certainly wouldn't pass unvalidated input through to your
business logic would you? You wouldn't return unencoded output to the people who
have lovingly chosen to use your site because you don't hate them. RIGHT!?!?!!

=end pod
