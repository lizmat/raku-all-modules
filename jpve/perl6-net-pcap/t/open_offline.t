use v6;
BEGIN { @*INC.unshift: 'blib/lib', 'lib' }

use Test;
use Net::Pcap;

plan 5;

my $pcap = Net::Pcap.open_offline('t/http.cap');
my ($hdr, $frame) = $pcap.next_ex();
$pcap.close();

is $hdr.seconds, 1084443427.31122,
    'Decodes seconds correctly';
    
is $hdr.caplen, 62,
    'Decodes captured length correctly';

is $hdr.len, 62,
    'Decodes length correctly';
    
sub MAC($frame, $i) {
    sprintf('%02X:%02X:%02X:%02X:%02X:%02X',
	$frame[$i],     $frame[$i + 1], $frame[$i + 2],
        $frame[$i + 3], $frame[$i + 4], $frame[$i + 5]);
}

my $dst = MAC($frame, 0);
my $src = MAC($frame, 6);

is $src, '00:00:01:00:00:00',
    'Decodes ethernet source correctly';
is $dst, 'FE:FF:20:00:01:00',
    'Decode ethernet destination correctly';

done();