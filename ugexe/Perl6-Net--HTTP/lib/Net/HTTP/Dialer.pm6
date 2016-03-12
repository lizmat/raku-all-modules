use Net::HTTP::Interfaces;

sub CAN-SSL(--> Bool) { (try require IO::Socket::SSL) !~~ Nil ?? True !! False }

# Get a scheme appropriate connected socket
role Net::HTTP::Dialer does Dialer {
    method can-ssl { state $ssl = ?CAN-SSL() }
    method dial(Request $req) {
        my $scheme = $req.url.scheme // 'http';
        my $host   = $req.url.host;
        my $port   = +($req.url.port // ($scheme eq 'https' ?? 443 !! 80));

        my $client-socket = IO::Socket::INET.new( :$host, :$port );

        given $scheme {
            when 'https' {
                die "Please install IO::Socket::SSL to use https" unless self.can-ssl;
                return ::('IO::Socket::SSL').new( :$client-socket );
            }
            when 'http'  { return $client-socket          }
            default      { die "Scheme: '$scheme' is NYI" }
        }
    }
}
