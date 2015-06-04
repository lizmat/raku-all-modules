use v6;
BEGIN {@*INC.unshift: './blib/lib' }

use Test;

my $mac_dst = Buf.new([0x00, 0x11, 0x22, 0x33, 0x44, 0x55]);
my $mac_dst_Int = 0x001122334455;
my $mac_src = Buf.new([0x66, 0x77, 0x88, 0x99, 0xAA, 0xBB]);
my $mac_src_Int = 0x66778899AABB;
my $mac_src_Str = '66:77:88:99:AA:BB';
my $ethertype = Buf.new([0x08, 0x00]);
my $ethertype_Int = 0x0800;
my $ethernet_hdr = $mac_dst ~ $mac_src ~ $ethertype;

my sub subtestdiag($desc, &subtests) {
    say '    # ' ~ $desc;
    subtest(&subtests, $desc);
}

diag('Net::Packet::Ethernet');
plan 2;

subtestdiag 'MAC_addr.unpack: Decode MAC address', {
    plan 2;
    
    use Net::Packet::Ethernet :short;

    my $mac = MAC_addr.unpack($mac_src, 0);
    is $mac.Int, $mac_src_Int,
	'.Int: Decodes address';
    is $mac.Str, $mac_src_Str,
        '.Str: Formats to string';
};
    

subtestdiag 'Ethernet.decode: Decode Ethernet header', {
    plan 6;
    
    use Net::Packet::Ethernet :short;
    
    my $eth = Ethernet.decode($ethernet_hdr);
    isa-ok $eth.src, MAC_addr,
	'.src: Decodes source address to a MAC_addr object';
    is $eth.src.Int, $mac_src_Int,
	'.src: Decodes source address correctly';

    isa-ok $eth.dst, MAC_addr,
        '.dst: Decodes destination address to a MAC_addr object';
    is $eth.dst.Int, $mac_dst_Int,
        '.dst: Decodes destination address correctly';

    isa-ok $eth.type, EtherType,
	'.type: Decodes type to EtherType';
    is $eth.type.Int, $ethertype_Int,
	'.type: Decodes EthernetType';
};
    
done;