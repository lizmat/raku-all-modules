use v6;
BEGIN { @*INC.unshift: 'blib/lib' }

use Test;

my $type_Int = 0x08;
my $code_Int = 0x00;
my $chksum_Int = 0xCAFE;
my $chksum = Buf.new([0xCA, 0xFE]);
my $hdr = Buf.new([0x12, 0x34, 0x56, 0x78]);
my $id_Int = 0x1234;
my $seqno_Int = 0x5678;

my $icmp_pkt = Buf.new([$type_Int, $code_Int]) ~ $chksum ~ $hdr;

my sub subtestdiag($desc, &subtests) {
    say '    # ' ~ $desc;
    subtest(&subtests, $desc);
}

diag('Net::Packet::ICMP');
plan 1;

subtestdiag 'ICMP.decode', {
    plan 5;
    
    use Net::Packet::ICMP :short;

    my $icmp = ICMP.decode($icmp_pkt);

    is $icmp.type, $type_Int,
	'Decodes type field correctly';
    is $icmp.code, $code_Int,
        'Decodes code field correctly';
    is $icmp.chksum, $chksum_Int,
	'Decodes checksum field correctly';

    is $icmp.id, $id_Int,
        'Decodes id field correctly';
    is $icmp.sequence_number, $seqno_Int,
	'Decodes sequence number field correctly';
};