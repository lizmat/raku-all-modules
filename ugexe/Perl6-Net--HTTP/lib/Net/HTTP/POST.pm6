use Net::HTTP::Interfaces;
use Net::HTTP::Transport;
use Net::HTTP::Request;
use Net::HTTP::Response;
use Net::HTTP::URL;

class Net::HTTP::POST {
    proto method CALL-ME(|) {*}
    multi method CALL-ME(Str $abs-url, :%header is copy, :$body?, |c --> Response) {
        my $url = Net::HTTP::URL.new($abs-url);
        with Net::HTTP::Request.new(:$url, :$body, :method<POST>, :User-Agent<perl6-net-http>) -> $req {
            temp %header<Connection> //= <keep-alive>;
            temp %header<User-Agent> //= <perl6-net-http>;
            $req.body   = $body || Buf.new;
            $req.header = %header;
            samewith($req, |c);
        }
    }

    multi method CALL-ME(Request $req, Response ::RESPONSE = Net::HTTP::Response --> Response) {
        state $transport = Net::HTTP::Transport.new;
        $transport.round-trip($req, RESPONSE) but ResponseBodyDecoder;
    }
}
