use v6;

use Smack::Response;
use Cofra::Web::Response;
use HTTP::Headers;
use X::Cofra::Web::Error;

unit class Cofra::Web::Response::P6WAPI does Cofra::Web::Response;

has Smack::Response $.response handles <
    status headers header Content-Length Content-Type body
    redirect finalize to-app
>;

method from-error(Cofra::Web::Response::P6WAPI:U: Exception $error --> Cofra::Web::Response::P6WAPI) {

    # TODO .from-error really ought to be pulled up into Cofra::Web::Response.

    my $response = do given $error {
        when X::Cofra::Web::Error {
            my $headers = HTTP::Headers.new;
            my @body = '<h1>', .status-message, '</h1>';

            $headers.Content-Type   = 'text/html; charset=ascii';
            $headers.Content-Length = @body.join.chars;

            Smack::Response.new(
                status  => .status,
                :$headers, :@body,
            );
        }

        default {
            my @body = "Internal Server Error";

            my $headers = HTTP::Headers.new;
            $headers.Content-Type   = 'text/plain; charset=ascii';
            $headers.Content-Length = @body.join.chars;

            Smack::Response.new(
                status  => 500,
                :$headers, :@body,
            );
        }
    }

    Cofra::Web::Response::P6WAPI.new(:$response);
}

=begin pod

=head1 NAME

Cofra::Web::Response::P6WAPI - web responses to P6WAPI servers

=head1 DESCRIPTION

This implements the L<Cofra::Web::Response> interface for P6WAPI servers.

=head1 METHOD

=head2 method response

    has Smack::Response $.response handles <
        status headers header Content-Length Content-Type body
        redirect finalize to-app
    >;

Provides the implementation of most the methods in this class by delegating them
to a wrapped L<Smack::Response> object.

=head2 method from-error

    method from-error(Cofra::Web::Response::P6WAPI:U: Exception $error --> Cofra::Web::Response::P6WAPI)

This can generate a P6WAPI response from any exception.

=end pod
