use Net::HTTP::Interfaces;
use Net::HTTP::Utils;

# defaults
use Net::HTTP::Dialer;
use Net::HTTP::Response;
use Net::HTTP::Request;

# Higher level HTTP transport for creating a custom HTTP::Client
# similar to ::GET and ::POST but made for reuse (connection caching and other state control)

class Net::HTTP::Transport does RoundTripper {
    also does Net::HTTP::Dialer;
    has %!connections;
    has $!lock = Lock.new;

    # mix in a proxy role and the host and request target url are set appropriately automatically
    # method proxy { ::('Net::HTTP::URL').new("http://proxy-lord.org") }

    method round-trip(Request $req, Response ::RESPONSE = Net::HTTP::Response --> Response) {
        self.hijack($req);

        # MAKE REQUEST
        my $socket := $.get-socket($req);
        $socket.write($req.?raw // $req.Str.encode);

        my $status-line   = $socket.get(:bin).unpack('A*');

        my @header-lines  = $socket.lines(:bin).map({$_ or last})>>.unpack('A*');
        my %header andthen do { %header{hc(.[0])}.append(.[1].trim-leading) for @header-lines>>.split(':', 2) }

        my $body    = buf8.new;
        my $buffer  = do with %header<Content-Length> { +$_.[0] } // Inf;
        my $chunked = do with %header<Transfer-Encoding> { .any ~~ /[:i chunked]/ } ?? True !! False;
        $socket.supply(:$buffer, :$chunked).tap: { $body ~= $_ }, done => {
            with %header<Connection> { .any ~~ /[:i close]/ ?? $socket.close !! $socket.release }
        }

        my $res = RESPONSE.new(:$status-line, :$body, :%header);

        $res;
    }

    # no private multi methods :(
    multi method hijack(Request $req) {
        my $header := $req.header;
        my $proxy   = self.?proxy;

        # set the host field to either an optional proxy's url host or the request's url host
        $header<Host>  = $proxy ?? $proxy.host !! $req.url.host;

        # override any possible default start-line() method behavior of using a relative request target url if $proxy
        $req does role :: { method path {$ = ~$req.url } } if $proxy;

        # automatically handle content-length setting
        $header<Content-Length> = !$req.body ?? 0 !! $req.body ~~ Blob ?? $req.body.bytes !! $req.body.encode.bytes;

        $header<Connection> //= 'keep-alive';
    }

    method get-socket(Request $req) {
        $!lock.protect({
            my $connection;

            # index connections by:
            my $scheme    = $req.url.scheme;
            my $host      = $req.header<Host>;
            my $usable   := %!connections{$*THREAD}{$host}{$scheme};

            if $usable -> $conns {
                for $conns.grep(*.closing.not) -> $sock {
                    # don't wait too long for a new socket before moving on
                    next unless await Promise.anyof( $sock.promise, start { $ = Promise.in(3); False });
                    next if $sock.promise.status ~~ Broken;
                    last if $connection = $sock.init;
                }
            }

            if $connection.not {
                $connection = $.dial($req) but IO::Socket::HTTP;
                $connection.init;

                $usable.append($connection) unless $req.header<Connection>.any ~~ /[:i close]/;
            }

            $connection.closing = True if $req.header<Connection>.any ~~ /[:i close]/;

            $connection;
        });
    }
}
