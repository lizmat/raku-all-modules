use v6;
use Test;
use Subsets::Common;
use Net::IP::Parse;

lives-ok {
    my IP $ip = IP.new(addr=><1.2.3.4>);
    is ($ip.version == 4), True, 'is ipv4';
    my IP $ip2 = IP.new(octets=>Array[UInt8].new(1,2,3,4));
    is ($ip ip== $ip2), True, 'constructors equivalent';
}, 'valid';

lives-ok {
    my IP $ip = IP.new(addr=>'dfea:dfea:dfea:dfea:dfea:dfea:dfea:dfea');
    is ($ip.version == 6), True, 'is ipv6';
    my IP $ip2 = IP.new(octets=>Array[UInt8].new(223,234,223,234,223,234,223,234,223,234,223,234,223,234,223,234));
    is ($ip2.version == 6), True, 'is ipv6';
    is ($ip ip== $ip2), True, 'constructors equivalent';
}, 'valid';

dies-ok {
    my IP $ip = IP.new(octets=>Array[UInt8].new(1,2,3));
}, 'undersized octets array';

dies-ok {
    my IP $ips = IP.new(addr=><1.2.3>);
}, 'undersized octets array';

dies-ok {
    my IP $ip = IP.new(octets=>Array[UInt8].new(1,2,3,256));
}, 'overflow octet';

dies-ok {
    my IP $ip = IP.new(addr=><1.2.3.256>);
}, 'overflow octet';

dies-ok {
    my IP $ip = IP.new(octets=>Array[UInt8].new(-1,2,3,255));
}, 'underflow octet';

dies-ok {
    my IP $ip = IP.new(addr=><-1.2.3.255>);
}, 'underflow octet';

dies-ok {
    my IP $ip = IP.new(octets=>Array[UInt8].new(1,2,3,4,5));
}, 'oversized octets array';

dies-ok {
    my IP $ip = IP.new(addr=><1.2.3.4.5>);
}, 'oversized octets array';

dies-ok {
    my IP $ip = IP.new(octets=>Array[UInt8].new(-1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16));
}, 'underflow octet';

dies-ok {
    my IP $ip = IP.new(addr=>'ffff:-1::ffff');
}, 'underflow octet';

dies-ok {
    my IP $ip = IP.new(octets=>Array[UInt8].new(256,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16));
}, 'overflow octet';

dies-ok {
    my IP $ip = IP.new(addr=>'ffff0:1::ffff');
}, 'overflow octet';

dies-ok {
    my IP $ip = IP.new(octets=>Array[UInt8].new(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15));
}, 'undersized octets array';

dies-ok {
    my IP $ip = IP.new(addr=>'ffff:ffff')
}, 'undersized octets array';

dies-ok {
    my IP $ip = IP.new(octets=>Array[UInt8].new(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17));
}, 'oversized octets array';

dies-ok {
    my IP $ip = IP.new(addr=>'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff')
}, 'oversized octets array';

lives-ok {
    my $ip = IP.new(addr=><1.2.3.4>);
    is ($ip.str eq '1.2.3.4'), True, 'str is valid';
}, 'valid string output';

lives-ok {
    my $s = 'dfea:dfea:dfea:dfea:dfea:dfea:dfea:dfea';
    my IP $ip = IP.new(addr=>$s);
    is ($ip.str eq $s), True, 'str is valid';
}, 'valid string output';

lives-ok {
    my $ip0 = IP.new(addr=>'8.8.8.8');
    my $ip1 = IP.new(addr=>'8.8.8.0');
    is ($ip0 ip== $ip0), True, 'addrs are equivalent';
    is ($ip0 ip== $ip1), False, 'addrs are not equivalent';
    is ($ip0 ip>= $ip1), True, 'lhs gt rhs';
    is ($ip1 ip<= $ip0), True, 'lhs gt rhs';
}, 'valid ipv4 comparisons';

lives-ok {
    my $ip0 = IP.new(addr=>'dfea:dfea:dfea:dfea:dfea:dfea:dfea:dfea');
    my $ip1 = IP.new(addr=>'dfea:dfea:dfea:dfea:dfea:dfea:dfea:df00');
    is ($ip0 ip== $ip0), True, 'addrs are equivalent';
    is ($ip0 ip== $ip1), False, 'addrs are not equivalent';
    is ($ip0 ip>= $ip1), True, 'lhs gt rhs';
    is ($ip1 ip<= $ip0), True, 'lhs gt rhs';
}, 'valid ipv6 comparisons';

lives-ok {
    my IP $ip = IP.new(addr=><::1>);
    is ($ip.version == 6), True, 'is ipv6';
}, 'valid';

sub array_eq(@a, @b) {
    return False if @a.elems != @b.elems;
    for 0..^@a.elems -> $i {
        return False if @a[$i] != @b[$i];
    }
    return True;
}

lives-ok {
    my IP $ip = IP.new(addr=><1::>);
    my @octets = 0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
    is (($ip.version == 6) && (array_eq $ip.octets, @octets)), True, 'is ipv6';
}, 'valid';

lives-ok {
    my IP $ip = IP.new(addr=><2001:db8:a0b:12f0::1>);
    my @octets = 32,1,13,184,10,11,18,240,0,0,0,0,0,0,0,1;
    is ($ip.version == 6), True, 'is ipv6';
}, 'valid';

lives-ok {
    my IP $ip = IP.new(addr=><1:2:3:4:5:6:7:8>);
    my @octets = 0,1,0,2,0,3,0,4,0,5,0,6,0,7,0,8;
    is (($ip.version == 6) && (array_eq $ip.octets, @octets)), True, 'is ipv6';
}, 'valid';

dies-ok {
    my $ip = IP.new(addr=><1::10000>);
}, 'address overflow detected';

dies-ok {
    my $ip = IP.new(addr=><1::-1>);
}, 'address underflow detected';

lives-ok {
    my IP $ip = IP.new(addr=><2001:db8:a0b:12f0::1%eth0>);
    is (($ip.version == 6) && ($ip.zone_id eq 'eth0')), True, 'is ipv6 with zone id';
}, 'valid';

dies-ok {
    my IP $ip = IP.new(addr=><2001:db8:a0b:12f0::1:1:1>);
}, 'bad addr detected';

dies-ok {
    my IP $ip = IP.new(addr=><1:2:3:4:5:6:7:8:9>);
}, 'bad addr detected';

dies-ok {
    my IP $ip = IP.new(addr=><2001:db8:a0b:12f0::1%>);
}, 'empty zone detected';

dies-ok {
    my IP $ip = IP.new(addr=>'');
}, 'empty address detected';

dies-ok {
    my IP $ip = IP.new(addr=><%eth0>);
}, 'empty address detected';

lives-ok {
    my IP $ip = IP.new(addr=><2001:db8:a0b:12f0::1:1>);
    is ($ip.str eq '2001:db8:a0b:12f0:0:0:1:1'), True, 'str is valid';
    my IP $ip2 = IP.new(addr=><2001:db8:a0b:12f0:0:0:1:1>);
    is ($ip ip== $ip2), True, 'equivalent forms';
}, 'valid string output';

lives-ok {
    my IP $ip = IP.new(addr=><1:0:0:1:0:0:0:1>);
    my $compressed = $ip.compress_str;
    is ($compressed eq '1:0:0:1::1'), True, 'compressed';
}, 'valid compress';

lives-ok {
    my IP $ip = IP.new(addr=><2001:db8:a0b:12f0::1:1>);
    my $compressed = $ip.compress_str;
    is ($compressed eq '2001:db8:a0b:12f0::1:1'), True, 'compressed';
}, 'valid compress';

lives-ok {
    my IP $ip = IP.new(addr=><2001:db8::>);
    my $compressed = $ip.compress_str;
    is ($compressed eq '2001:db8::'), True, 'compressed';
}, 'valid compress';

lives-ok {
    my IP $ip = IP.new(addr=><1:1:0:0:0:0:0:0>);
    my $compressed = $ip.compress_str;
    is ($compressed eq '1:1::'), True, 'compressed';
}, 'valid compress';

lives-ok {
    my IP $ip = IP.new(addr=><0:0:0:0:0:0:0:1>);
    my $compressed = $ip.compress_str;
    is ($compressed eq '::1'), True, 'compressed';
}, 'valid compress';

lives-ok {
    my IP $ip = IP.new(addr=><1:0:0:0:1:0:0:1>);
    my $compressed = $ip.compress_str;
    is ($compressed eq '1::1:0:0:1'), True, 'compressed';
}, 'valid compress';

lives-ok {
    my $s = '::ffff:ffff:ffff:ffff:ffff:ffff';
    my IP $ip = IP.new(addr=>$s);
    my IP $ref = IP.new(addr=>'0:0:ffff:ffff:ffff:ffff:ffff:ffff');
    is ($ip ip== $ref), True, 'equivalent with reference';
    my $compressed = $ip.compress_str;
    is ($compressed eq $s), True, 'compressed';
    
}, 'valid compress';

lives-ok {
    my CIDR $cidr = CIDR.new(cidr=>'8.8.8.8/16');
    my IP $addr = IP.new(addr=><8.8.8.8>);   
    is ($addr ip== $cidr.addr), True, 'addr equal';
    my IP $prefix_addr = IP.new(addr=><255.255.0.0>);
    is ($prefix_addr ip== $cidr.prefix_addr), True, 'prefix equal';
    my IP $wildcard_addr = IP.new(addr=><0.0.255.255>);
    is ($wildcard_addr ip== $cidr.wildcard_addr), True, 'wildcard equal';
    my IP $network_addr = IP.new(addr=><8.8.0.0>);
    is ($network_addr ip== $cidr.network_addr), True, 'network equal';
    my IP $broadcast_addr = IP.new(addr=><8.8.255.255>);
    is ($broadcast_addr ip== $cidr.broadcast_addr), True, 'broadcast equal';
}, 'valid ipv4 cidr';

lives-ok {
    my CIDR $cidr = CIDR.new(cidr=>'2001:db8::/32');
    my IP $addr = IP.new(addr=>'2001:0db8:0000:0000:0000:0000:0000:0000');
    is ($addr ip== $cidr.addr), True, 'addr equal';
    my IP $prefix_addr = IP.new(addr=>'ffff:ffff::');
    is ($prefix_addr ip== $cidr.prefix_addr), True, 'prefix equal';
    my IP $wildcard_addr = IP.new(addr=>'0:0:ffff:ffff:ffff:ffff:ffff:ffff');
    is ($wildcard_addr ip== $cidr.wildcard_addr), True, 'wildcard equal';
    my IP $network_addr = IP.new(addr=>'2001:db8:0:0:0:0:0:0');
    is ($network_addr ip== $cidr.network_addr), True, 'network equal';
    my IP $broadcast_addr = IP.new(addr=>'2001:db8:ffff:ffff:ffff:ffff:ffff:ffff');
    is ($broadcast_addr ip== $cidr.broadcast_addr), True, 'broadcast equal';
}, 'valid ipv6 cidr';

lives-ok {
    my CIDR $cidr = CIDR.new(cidr=>'8.8.8.8/16');
    my IP $addr = IP.new(addr=>'8.8.0.0');
    is ($addr in_cidr $cidr), True, 'ip in cidr';
    $addr = IP.new(addr=>'8.8.2.2');
    is ($addr in_cidr $cidr), True, 'ip in cidr';
    $addr = IP.new(addr=>'8.8.255.255');
    is ($addr in_cidr $cidr), True, 'ip in cidr';
}, 'valid "in cidr"';

lives-ok {
    my CIDR $cidr = CIDR.new(cidr=>'2001:db8::/32');
    my IP $addr = IP.new(addr=>'2001:0db8:0000:0000:0000:0000:0000:0000');
    is ($addr in_cidr $cidr), True, 'ip in cidr';
    $addr = IP.new(addr=>'2001:db8:ffff:ffff:ffff:ffff:ffff:0001');
    is ($addr in_cidr $cidr), True, 'ip in cidr';
    $addr = IP.new(addr=>'2001:db8:ffff:ffff:ffff:ffff:ffff:ffff');
    is ($addr in_cidr $cidr), True, 'ip in cidr';
}, 'valid "in cidr"';

lives-ok {
    my CIDR $cidr = CIDR.new(cidr=>'8.8.8.8/16');
    my IP $addr = IP.new(addr=>'8.9.0.0');
    is ($addr in_cidr $cidr), False, 'ip not in cidr';
}, 'valid not "in cidr"';

lives-ok {
    my CIDR $cidr = CIDR.new(cidr=>'2001:db8::/32');
    my IP $addr = IP.new(addr=>'2001:0db9:0000:0000:0000:0000:0000:0000');
    is ($addr in_cidr $cidr), False, 'ip not in cidr';
}, 'valid not "in cidr"';

dies-ok {
    my CIDR $cidr = CIDR.new(cidr=>'2001:db8::/32');
    my IP $addr = IP.new(addr=>'8.8.0.0');
    is ($addr in_cidr $cidr), True, 'ip in cidr';
}, 'detected version mismatch';

dies-ok {
    my CIDR $cidr = CIDR.new(cidr=>'8.8.8.8/16');
    my IP $addr = IP.new(addr=>'2001:0db8:0000:0000:0000:0000:0000:0000');
    is ($addr in_cidr $cidr), True, 'ip in cidr';
}, 'detected version mismatch';

done-testing;
