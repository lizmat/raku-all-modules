use v6;
BEGIN {@*INC.unshift: './blib/lib' }

use Test;

my $src_port = Buf.new([0xCA, 0xFE]);
my $src_port_Int = 0xCAFE;
my $dst_port = Buf.new([0xBE, 0xEF]);
my $dst_port_Int = 0xBEEF;
my $length = Buf.new([0xAB, 0xCD]);
my $length_Int = 0xABCD;
my $chksum = Buf.new([0x12, 0x34]);
my $chksum_Int = 0x1234;
my $udp_hdr = $src_port ~ $dst_port ~ $length ~ $chksum;

my sub subtestdiag($desc, &subtests) {
    say '    # ' ~ $desc;
    subtest(&subtests, $desc);
}

diag('Net::Packet::UDP');
plan 1;

subtestdiag 'UDP.decode: Decode UDP header', {
    plan 4;
    
    use Net::Packet::UDP :short;
    
    my $udp = UDP.decode($udp_hdr);
    is $udp.src_port, $src_port_Int,
	'.src_port: Decodes source port correctly';
    is $udp.dst_port, $dst_port_Int,
	'.dst_port: Decodes destination port correctly';

    is $udp.length, $length_Int,
	'.length: Decodes length correctly';
    is $udp.dst_port.Int, $dst_port_Int,
	'.chksum: Decodes chksum correctly';
};
    
done;