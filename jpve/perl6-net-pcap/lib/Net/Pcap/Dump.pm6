use NativeCall;
use Net::Pcap;
use Net::Pcap::C_Buf;
use Net::Pcap::Linktype;

=NAME
Net::Pcap::Dump - Write packets to file.

=begin SYNOPSIS
    use Net::Pcap::Dump :short;
    use Net::Pcap::Linktype :short;
    use Net::Pcap::C_Buf :short;

    my $data = C_Buf.new(Buf.new([0x00, 0x01, 0x02, 0x03]));
    my $dump = Dumper.open('dump.pcap', Linktype::Ethernet, 1500);
    $dump.dump($data);
=end SYNOPSIS

=begin EXPORTS
    class Net::Pcap::Dump;

:short trait adds export:

    constant Dump ::= Net::Pcap::Dump;
=end EXPORTS

=DESCRIPTION

=head2 class Net::Pcap::Dump
=begin code
Implements `pcap_dump_t`.
=end code

unit class Net::Pcap::Dump;

my constant Dump is export(:short) ::= Net::Pcap::Dump;



=head3 Attributes
=begin code
$.pcap_dump  is rw  is OpaquePointer
  Pointer to the pcap_dump_t structure.

$.pcap       is rw  is Net::Pcap
  Parent pcap_t structure.
=end code

has OpaquePointer $.pcap_dump is rw;
has Net::Pcap $.pcap is rw;



my sub pcap_dump_open(Net::Pcap $p, Str $fname)
    returns OpaquePointer
    is native('libpcap') { * };
my sub pcap_dump_close(OpaquePointer $p)
    is native('libpcap') { * };

my sub pcap_dump(OpaquePointer $user, Net::Pcap::pcap_pkthdr_t $h, OpaquePointer $p)
    is native('libpcap') { * };

my sub pcap_geterr(Net::Pcap $p)
    returns Str
    is native('libpcap') { * };

=head3 Methods

=begin code
.open(Net::Pcap $p, Str $fname) returns Net::Pcap::Dump
  Constructor for Net::Pcap::Dump. Calls pcap_dump_open($p, $fname).

.open(Str $fname, Net::Pcap::Linktype $linktype, Int $snaplen) returns Net::Pcap::Dump
  Constructor for Net::Pcap::Dump. Calls pcap_open_dead and pcap_dump_open.
=end code

multi method open(Net::Pcap $p, Str $fname) {
    my $dump = pcap_dump_open($p, $fname);
    if !$dump {
	die("Pcap::Dumper->open: " ~ pcap_geterr($p));
    }
    self.bless(:$dump);
}

multi method open(Str $fname, Net::Pcap::Linktype $linktype, Int $snaplen) {
    my $pcap = Net::Pcap.open_dead($linktype.value, $snaplen);
    if !$pcap {
	die("Dump.open: Could not open_dead");
    }
    my $pcap_dump = pcap_dump_open($pcap, $fname);
    if !$pcap_dump {
	die("Dump.open: Could not dump_open" ~ pcap_geterr($pcap));
    }
    self.new(:$pcap, :$pcap_dump);
}



=begin code
.close()
  Closes the pcap_dump_t, and (if constructed by .open()) closes the parent pcap_t.
=end code

method close() {
    pcap_dump_close($.pcap_dump) if $.pcap_dump;
    $.pcap.close() if $.pcap;
}



=begin code
.dump(Net::Pcap::C_Buf $data, Real $seconds)
  Write packet to file. Constructs a pcap_pkthdr_t with caplen and len from C_Buf.elems,
  and tv_usec and tv_sec from $seconds. Then calls pcap_dump on the data and the pcap_pkthdr_t
  structure.
=end code

method dump(Net::Pcap::C_Buf $data, Real $secs) {
    my Int $tv_sec = $secs.floor;
    my Int $tv_usec = (($secs-$tv_sec)*1e6).floor;
    my Int $caplen = $data.bytes;
    my Int $len = $data.bytes;
    my $pkthdr = Net::Pcap::pcap_pkthdr_t.new(:$tv_sec, :$tv_usec, :$caplen, :$len);
    pcap_dump($.pcap_dump, $pkthdr, $data.ptr);
}

