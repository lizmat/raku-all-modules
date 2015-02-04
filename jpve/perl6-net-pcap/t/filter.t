use v6;
BEGIN { @*INC.unshift: 'blib/lib', 'lib' }

use Test;
use Net::Pcap;

plan 1;

my $pcap = Net::Pcap.open_offline('t/http.cap');
$pcap.filter('ether dst 00:00:01:00:00:00');
my ($hdr, $frame) = $pcap.next_ex();
$pcap.close();

is $hdr.seconds, 1084443428.22253,
    'Filters correctly';

done();
