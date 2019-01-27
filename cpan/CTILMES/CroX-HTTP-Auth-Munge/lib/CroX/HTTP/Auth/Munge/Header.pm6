use JSON::Fast;
use Munge;
use Cro::HTTP::Header;

sub munge($payload? --> Cro::HTTP::Header) is export
{
    my $cred = Munge.new.encode(to-json($payload));
    Cro::HTTP::Header.new(name => 'Authorization', value => "MUNGE $cred");
}
