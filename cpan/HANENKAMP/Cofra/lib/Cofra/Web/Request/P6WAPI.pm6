use v6;

use Smack::Request;
use Cofra::Web::Request;

unit class Cofra::Web::Request::P6WAPI does Cofra::Web::Request;

use Smack::Response;
use Cofra::Web::Response::P6WAPI;

# handles * would be nice, but rakudo 2018.10 barfs on it
has Smack::Request $.request handles <
    protocol method host port user request-uri path-info
    path query-string script-name scheme secure body
    input session session_options cookies
    query-parameters raw-content content headers
    body-parameters parameters param
>;

has %.env;

submethod BUILD(:%!env) {
    $!request .= new(%!env);
}

method router-context(--> Hash:D) {
    %(
        REQUEST_METHOD => %.env<REQUEST_METHOD>,
    )
}

method start-response(--> Cofra::Web::Response::P6WAPI:D) {
    my $response = Smack::Response.new(:200status);
    Cofra::Web::Response::P6WAPI.new(:$response);
}

=begin pod

=head1 NAME

Cofra::Web::Request::P6WAPI - request handling for P6WAPI servers

=head1 DESCRIPTION

A request for interfacing Cofra applications with P6WAPI servers.

=head1 METHODS

=head2 method request

    has Smack::Request $.request handles <
        protocol method host port user request-uri path-info
        path query-string script-name scheme secure body
        input session session_options cookies
        query-parameters raw-content content headers
        body-parameters parameters param
    >;

This class is a facade wrapping a L<Smack::Response> object.

=head2 method env

    has %.env is required

This is the P6WAPI environment that will be encapsulated in the
L<Smack::Response> inside the L<Cofra::Web::Request::P6WAPI>, like a turducken.

=head2 method router-context

    method router-context(--> Hash:D)

See the L<CAVEATS section|Cofra::Web::Request#CAVEATS> of L<Cofra::Web::Request>
for details.

=head2 method start-response

    method start-response(--> Cofra::Web::Response::P6WAPI:D)

Constructs and returns a L<Cofra::Web::Response::P6WAPI> object primed for
returning a response to this request.

=end pod
