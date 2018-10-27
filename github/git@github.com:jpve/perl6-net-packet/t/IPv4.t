use v6;
BEGIN {@*INC.unshift: './blib/lib'; }

use Test;

my $ip_dst = Buf.new([0x00, 0x11, 0x22, 0x33]);
my $ip_dst_Int = 0x00112233;
my $ip_src = Buf.new([0x66, 0x77, 0x88, 0x99]);
my $ip_src_Int = 0x66778899;
my $ip_src_Str = '102.119.136.153';
my $versionihl = Buf.new([0x45]);
my $version_Int = 0x4;
my $ihl_Int = 0x5;
my $dscp_Int = 0x8;
my $ecn_Int = 0x1;
my $dscpecn = Buf.new([$dscp_Int+<2 + $ecn_Int]);
my $total_length = Buf.new([0x8A, 0xA8]);
my $total_length_Int = 0x8AA8;
my $id = Buf.new([0xBE, 0xEF]);
my $id_Int = 0xBEEF;
my $flags_Int = 0x5;
my $fragment_offset_Int = 0x1ABC;
my $flagsfragmentoffset = Buf.new([$flags_Int+<5 + $fragment_offset_Int+>8, $fragment_offset_Int+&0xFF]);
my $ttlproto = Buf.new([0xCD, 0x06]);
my $ttl_Int = 0xCD;
my $proto_Int = 0x06;
my $hdr_chksum_Int = 0xCAFE;
my $hdr_chksum = Buf.new([0xCA, 0xFE]);
my $ip_hdr =   $versionihl ~ $dscpecn ~ $total_length ~ $id ~ $flagsfragmentoffset
    ~ $ttlproto ~ $hdr_chksum ~ $ip_src ~ $ip_dst;

my sub subtestdiag($desc, &subtests) {
    say '    # ' ~ $desc;
    subtest(&subtests, $desc);
}

diag('Net::Packet::IPv4');
plan 2;

subtestdiag 'IPv4_addr.unpack: Decode IPv4 address', {
    plan 2;
    
    use Net::Packet::IPv4 :short;

    my $ip = IPv4_addr.unpack($ip_src, 0);
    is $ip.Int, $ip_src_Int,
	'.Int: Decodes address';
    is $ip.Str, $ip_src_Str,
        '.Str: Formats to string';
};
    

subtestdiag 'IPv4.decode: Decode IPv4 header', {
    plan 15;
    
    use Net::Packet::IPv4 :short;

    my $ip = IPv4.decode($ip_hdr);
    is $ip.ihl, $ihl_Int,
        '.ihl: Decodes internet header length';
    is $ip.dscp, $dscp_Int,
	'.dscp: Decodes DSCP field';
    is $ip.ecn, $ecn_Int,
        '.ecn: Decodes ECN field';
    is $ip.total_length, $total_length_Int,
	'.total_length: Decodes total length field';
    is $ip.id, $id_Int,
        '.id: Decodes identification field';
    is $ip.flags, $flags_Int,
	'.flags: Decodes flags';
    is $ip.fragment_offset, $fragment_offset_Int,
        '.fragment_offset: Decodes fragment offset field';
    is $ip.ttl, $ttl_Int,
        '.ttl: Decodes ttl field';

    isa-ok $ip.proto, IP_proto,
        '.proto: Decodes proto field to IP_proto type';
    is $ip.proto.value, $proto_Int,
	'.proto: Decodes proto field';

    is $ip.hdr_chksum, $hdr_chksum_Int,
	'.hdr_chksum: Decodes header checksum field';

    isa-ok $ip.src, IPv4_addr,
    	'.src: Decodes source address to a IPv4_addr object';
    is $ip.src.Int, $ip_src_Int,
    	'.src: Decodes source address correctly';

    isa-ok $ip.dst, IPv4_addr,
        '.dst: Decodes destination address to a IPv4_addr object';
    is $ip.dst.Int, $ip_dst_Int,
        '.dst: Decodes destination address correctly';
	    
};

# TODO: Add test for 802.1Q/ad frames.

done;