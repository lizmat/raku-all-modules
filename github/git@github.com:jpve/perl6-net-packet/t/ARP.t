use v6;
BEGIN {@*INC.unshift: './blib/lib' }

use Test;

my $mac_dst = Buf.new([0x00, 0x11, 0x22, 0x33, 0x44, 0x55]);
my $mac_dst_Int = 0x001122334455;
my $mac_src = Buf.new([0x66, 0x77, 0x88, 0x99, 0xAA, 0xBB]);
my $mac_src_Int = 0x66778899AABB;
my $ip_dst = Buf.new([0x00, 0x11, 0x22, 0x33]);
my $ip_dst_Int = 0x00112233;
my $ip_src = Buf.new([0x66, 0x77, 0x88, 0x99]);
my $ip_src_Int = 0x66778899;
my $hw_type = Buf.new([0x00, 0x01]);
my $hw_type_Int = 0x01;
my $proto_type = Buf.new([0x08,0x00]);
my $proto_type_Int = 0x0800;
my $lens = Buf.new([0x06, 0x04]);
my $hw_len_Int = 0x06;
my $proto_len_Int = 0x04;
my $oper = Buf.new([0x00, 0x01]);
my $oper_Int = 0x0001;
my $arp_pkt = $hw_type~$proto_type~$lens~$oper~$mac_src~$ip_src~$mac_dst~$ip_dst;

my sub subtestdiag($desc, &subtests) {
    say '    # ' ~ $desc;
    subtest(&subtests, $desc);
}

diag('Net::Packet::ARP');
plan 1;

subtestdiag 'ARP.decode: Decode ARP packet', {
    plan 16;
    
    use Net::Packet::ARP :short;
    use Net::Packet::IPv4 :short;
    use Net::Packet::Ethernet :short;
    
    my $arp = ARP.decode($arp_pkt);
    isa-ok $arp.hw_type, ARP::HardwareType,
	'.hw_type: Decodes hardware type to ARP::HardwareType';
    is $arp.hw_type.value, $hw_type_Int,
	'.hw_type: Decodes hardware type';

    isa-ok $arp.proto_type, EtherType,
        '.proto_type: Decodes protocol type to EtherType';
    is $arp.proto_type.value, $proto_type_Int,
	'.proto_type: Decodes protocol type';

    is $arp.hw_len, $hw_len_Int,
	'.hw_len: Decodes hardware address length';
    is $arp.proto_len, $proto_len_Int,
	'.proto_len: Decodes protocol address length';

    isa-ok $arp.operation, ARP::Operation,
        '.operation: Decodes operation to ARP::Operation';
    is $arp.operation.value, $oper_Int,
	'.operation: Decodes operation code';

    isa-ok $arp.src_hw_addr, MAC_addr,
	'.src_hw_addr: Decodes source hardware address to MAC address';
    is $arp.src_hw_addr.Int, $mac_src_Int,
	'.src_hw_addr: Decodes source hardware address';
    isa-ok $arp.src_proto_addr, IPv4_addr,
	'.src_proto_addr: Decodes source protocol address to IPv4 address';
    is $arp.src_proto_addr.Int, $ip_src_Int,
	'.src_proto_addr: Decodes source ip address';

    isa-ok $arp.dst_hw_addr, MAC_addr,
	'.dst_hw_addr: Decodes source hardware address to MAC address';
    is $arp.dst_hw_addr.Int, $mac_dst_Int,
	'.dst_hw_addr: Decodes source hardware address';
    isa-ok $arp.dst_proto_addr, IPv4_addr,
	'.dst_proto_addr: Decodes source protocol address to IPv4 address';
    is $arp.dst_proto_addr.Int, $ip_dst_Int,
	'.dst_proto_addr: Decodes source ip address';
};
    
done;