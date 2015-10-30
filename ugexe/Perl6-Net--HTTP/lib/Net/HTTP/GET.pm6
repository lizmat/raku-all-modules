use Net::HTTP::Interfaces;
use Net::HTTP::Transport;
use Net::HTTP::Request;
use Net::HTTP::Response;
use Net::HTTP::URL;

# This will be changed to access the Client instead of the Transport later
class Net::HTTP::GET {
    proto method CALL-ME(|) {*}
    multi method CALL-ME(Str $abs-url, |c --> Response) {
        my $url = Net::HTTP::URL.new($abs-url);
        my $req = Net::HTTP::Request.new(:$url, :method<GET>, header => :Connection<keep-alive>, :User-Agent<perl6-net-http>);
        samewith($req, |c);
    }
    multi method CALL-ME(Request $req, Response ::RESPONSE = Net::HTTP::Response --> Response) {
        state $transport = Net::HTTP::Transport.new;
        $ = await start { $transport.round-trip($req) }
    }
}
