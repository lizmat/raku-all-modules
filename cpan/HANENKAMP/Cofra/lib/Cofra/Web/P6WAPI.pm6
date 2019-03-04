use v6;

unit role Cofra::Web::P6WAPI;

use Cofra::Web::Response;
use Cofra::Web::Request::P6WAPI;
use Cofra::Web::Response::P6WAPI;
use X::Cofra::Web::Error;

method app { ... }
method log-error { ... }

method p6wapi-request-response-dispatch(%env --> List) {
    try {
        my $req = Cofra::Web::Request::P6WAPI.new(:%env, :$.app);

        # Just in case someone has some middleware that needs these
        %env<cofra.app>     = $.app;
        %env<cofra.web>     = self;
        %env<cofra.request> = $req;

        my $res = self.request-response-dispatch($req);

        CATCH {
            when X::Cofra::Web::Error {
                $res = Cofra::Web::Response::P6WAPI.from-error($_);
                return $res.finalize;
            }
            default {
                self.log-error($_);
                $res = Cofra::Web::Response::P6WAPI.from-error(
                    X::Cofra::Web::Error.new(self, $req)
                );
                return $res.finalize;
            }
        }

        $res.finalize;
    }
}

=begin pod

=head1 NAME

Cofra::Web::P6WAPI - not yet documented

=head1 DESCRIPTION

This provides the tooling to wrap the dispatch methods of L<Cofra::Web> and
adapts those methods to work with a P6WAPI server.

=head1 METHODS

=head2 method p6wapi-request-response-dispatch

    method p6wapi-request-response-disaptch(%env --> List)

This is a partial implementation of a P6WAPI request-response method. The
difference is that this is a method requiring an invocant and it does not return
asynchronously. This code will turn it into a proper P6WAPI request-response method:

    sub (%env --> Promise) {
        start {
            $web.p6wapi-request-response-dispatch(%env);
        }
    }



=end pod
