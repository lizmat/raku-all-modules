use Cro::HTTP::Middleware;
use Cro::HTTP::Request;
use Cro::HTTP::Response;
use Cro::Uri;

=begin pod

=head1 NAME

CroX::HTTP::FallbackPassthru - dumb passthru proxy middleware for Cro

=head1 SYNOPSIS

    use Cro::HTTP::Router;
    use Cro::HTTP::Server;
    use CroX::HTTP::FallbackPassthrue;

    my $application = route { ... };
    my $fallback = CroX::HTTP::FallbackPassthru.new(
        forward-uri => Cro::Uri.parse('http://localhost:12345'),
    );

    my Cro::Service $service = Cro::HTTP::Server.new(
        host        => 'localhost',
        port        => 8080,
        application => $application,
        after       => ($fallback,),
    );

    $service.start;

=head1 DESCRIPTION

You should probably only ever use this in development. In production there are smarter ways to do reverse proxying. However, if you need a dumb reverse proxy during development, this can do it.

Basically, this is Cro middleware that will try to forward the request on to another server when the router for this application returns a 404. The forwarding is done by making a client call from this server to the forwarded server using the same request object. The response from the client is then passed back through.

=head1 METHODS

In case you have some need to extend the middleware, here's a description of the methods.

=head2 method forward-uri

    has Cro::Uri $.forward-uri

This is the URI of the passthrough service.

=head2 method should-fallback

    method should-fallback(Cro::HTTP::Response $res -> Bool)

Given a response, this determines if fallback to the proxied service should be performed. The default implementation just checks to see if the response status is 404 and returns True in that case. It returns False in all others.

=head2 method client-uri

    method client-uri(Cro::HTTP::Request $req -> Cro::Uri)

Given a request, it creates the URI that should be contacted to perform the passthru proxying. This is done by appending the path and query of the request to this server to the URI returned by L<#method forward-uri>.

=head2 method process

    method process(Supply $responses --> Supply)

This is the method that puts it altogeher.

=end pod

class CroX::HTTP::FallbackPassthru:ver<0.1>:auth<github:zostay> does Cro::HTTP::Middleware::Response {
    has Cro::Uri $.forward-uri;

    method should-fallback(Cro::HTTP::Response $response --> Bool) {
        $response.status == 404
    }

    method client-uri(Cro::HTTP::Request $request --> Cro::Uri) {
        $!forward-uri.clone(
            path  => "$!forward-uri.path()$request.path()",
            query => $request.query,
        );
    }

    method process(Supply:D $responses) {
        use Cro::HTTP::Client;

        my $client = Cro::HTTP::Client.new(
            :host($!forward-uri.host),
            :port($!forward-uri.port),
        );

        supply {
            whenever $responses -> $response {
                if self.should-fallback($response) && $response.request -> $request {
                    my $uri = self.client-uri($request),
                    my $res = await $client.request($request.method, $uri);
                    emit $res;

                    CATCH {
                        when X::Cro::HTTP::Error {
                            # Uh, needing this seems like a bug
                            .response.remove-header('Transfer-encoding');
                            emit .response;
                        }
                        default {
                            .note;
                            emit $response;
                        }
                    }
                }
                else {
                    emit $response;
                }
            }
        }
    }
}
