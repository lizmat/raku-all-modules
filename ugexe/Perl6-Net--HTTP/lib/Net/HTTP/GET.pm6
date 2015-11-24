use Net::HTTP::Interfaces;
use Net::HTTP::Transport;
use Net::HTTP::Request;
use Net::HTTP::Response;
use Net::HTTP::URL;

our $transport = Net::HTTP::Transport.new;

class Net::HTTP::GET {
    proto method CALL-ME(|) {*}
    multi method CALL-ME(Str $abs-url, :$body, :%header is copy, |c --> Response) {
        my $url = Net::HTTP::URL.new($abs-url);
        with Net::HTTP::Request.new(:$url, :method<GET>) -> $req {
            temp %header<Connection> //= <keep-alive>;
            temp %header<User-Agent> //= <perl6-net-http>;
            $req.body   = $body || Buf.new;
            $req.header = %header;
            samewith($req, |c);
        }
    }
    multi method CALL-ME(Request $req, Response ::RESPONSE = Net::HTTP::Response --> Response) {
        self.round-trip($req, RESPONSE);
    }

    # a round-tripper that follow redirects
    proto method round-trip(|) {*}
    multi method round-trip($req, Response ::RESPONSE) {
        my $response = $transport.round-trip($req, RESPONSE) but ResponseBodyDecoder;
        given $response.status-code {
            when /^3\d\d$/ {
                # make an absolute url. this should be incorporated into Net::HTTP::URL
                with $response.header<Location>.first(*.so) -> $path {
                    my $url = Net::HTTP::URL.new: $path !~~ /^\w+ \: \/ \//
                        ?? "{$req.url.scheme}://{$req.url.host}{'/' unless $path.starts-with('/')}{$path}"
                        !! $path;
                    my $next-req := $req.new(:$url, :method<GET>, :body($req.body), :header($req.header));
                    $response = self.round-trip($next-req, RESPONSE);
                }
            }
        }
        $response;
    }
}
