use v6;

use Cofra::Web::Godly;
use X::Cofra::Error;

unit package X::Cofra::Web;

use HTTP::Status;

role Error[$status = 500] is X::Cofra::Error does Cofra::Web::Godly {
    use Cofra::Web::Request;

    has Cofra::Web::Request $.request;

    multi method new($web, $request, $cause?) {
        self.bless(:$web, :$request, :$cause);
    }

    method status(--> Int:D) { $status }
    method status-message(--> Str:D) { get_http_status_msg($status) }
}

class Error::BadRequest does X::Cofra::Web::Error[400] { }
class Error::Unauthorized does X::Cofra::Web::Error[401] { }
class Error::Forbidden does X::Cofra::Web::Error[403] { }
class Error::NotFound does X::Cofra::Web::Error[404] { }

=begin pod

=head1 NAME

X::Cofra::Web::Error - internal server error

=head1 SYNOPSIS

    X::Cofra::Web::Error.new($.web, $.request, "bad stuff");

    X::Cofra::Web::Error[405].new($.web, $.request, 'bad method');

=head1 DESCRIPTION

This exception represents an error in the web application. When used directly, you can specify the HTTP status code the error represents as a parameter to the role. A number of specialized subclasses are also defined.

=head1 METHODS

=head2 method request

    has Cofra::Web::Request $.request

This is the request that failed (if known).

=head2 method status

    method status(--> Int:D)

Returns the status code associated with the error. It is set by the parameter to the role and defaults to 500.

=head2 method status-message

    method status-message(--> Str:D)

Returns the message for the status code. For example, 500 will return "Internal Server Error".

=head1 SUBCLASSES

=head2 X::Cofra::Web::Error::BadRequest

Represents a 400 error.

=head2 X::Cofra::Web::Error::Unauthorized

Represents a 401 error.

=head2 X::Cofra::Web::Error::Forbidden

Represents a 403 error.

=head2 X::Cofra::Web::Error::NotFound

Represents a 404 error.

=end pod
