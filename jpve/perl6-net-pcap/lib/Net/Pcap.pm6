use NativeCall;
use Net::Pcap::C_Buf :short;
use Net::Pcap::Linktype :short;

=NAME
Net::Pcap - libpcap bindings

=begin SYNOPSIS
=begin code
use Net::Pcap;
use Net::Packet :short;

# Live capturing
my $pcap = Net::Pcap.create("eth0");
$pcap.filter('portrange 1-1024');
$pcap.activate;

# Read from file
my $pcap = Net::Pcap.offline_open('./capture.pcap');

loop $pcap.next_ex -> ($hdr, $frame) {
    my $eth = Ethernet.decode($frame);

    say sprintf 'Time:   %.3f', $hdr.seconds;
    say sprintf 'Length: %d (%d captured)', $hdr.len, $hdr.caplen;
    say sprintf 'Ethernet:';
    say sprintf '  Source:      %s', $eth.src;
    say sprintf '  Destination: %s', $eth.dst;

    if $eth.pl ~~ IPv4 {
     	say sprintf 'IPv4:';
	say sprintf '  Source:      %s', $eth.pl.src;
	say sprintf '  Destination: %s', $eth.pl.dst;
    }
}
=end code
=end SYNOPSIS

=begin EXPORTS
    class Net::Pcap
=end EXPORTS

=begin DESCRIPTION

=end DESCRIPTION


    
=head2 class Net::Pcap::pcap_pkthdr_t

=begin code
is repr('CStruct')

Implements `pcap_pkthdr_t`.
=end code

unit class Net::Pcap is repr('CPointer');

my constant Pcap is export(:short) ::= Net::Pcap;



class pcap_pkthdr_t is repr('CStruct') {
=head3 Attributes

=begin code
$.tv_sec   is int
$.tv_usec  is int
$.caplen   is int
$.len      is int
=end code

    # struct timeval_t {
    #   * Linux:
    #   *  One place where the 32- and 64-bit modes differ is in their representation of time
    #   *  values; in the 32-bit world, types like time_t, struct timespec, and struct timeval
    #   *  are 32-bit quantities.
    #   *   - http://lwn.net/Articles/456731/
        has int $.tv_sec;
        has int $.tv_usec;
    # }
    has int32 $.caplen;
    has int32 $.len;

=head3 Methods

=begin code
.seconds() returns Real
  Combines the $.tv_sec and $.tv_usec fields to one Real.
=end code

    method seconds() returns Real {
	$.tv_sec + $.tv_usec*1e-6;
    }

=begin code
.clone() returns Net::Pcap::pcap_pkthdr_t
  Returns a copy of this structure.
=end code

    method clone() returns pcap_pkthdr_t {
	pcap_pkthdr_t.new(
	    tv_sec => $.tv_sec,
	    tv_usec => $.tv_usec,
	    caplen => $.caplen,
	    len => $.len
	);
    }
}



# Structs

class pcap_pkthdrp_t is repr('CStruct') {
    has pcap_pkthdr_t $.hdr; # **pcap_pkthdr_t
}

my class u_charp_t is repr('CStruct') {
    has OpaquePointer $.u_char; # **u_char
}

my class bpf_program_t is repr('CStruct') {
    has uint32 $.bf_len;           # u_int32
    has OpaquePointer $.bf_insns; # *bpf_insn_t
}

my class pcap_if_t is repr('CStruct') {
    has pcap_if_t $.next;
    has Str $.name;
    has Str $.description;
    has OpaquePointer $.addresses;    # TODO: add support for addresses in pcap_if_t struct
    has int32 $.flags;
}

my class pcap_ifp_t is repr('CStruct') {
    has pcap_if_t $.if;
}



=head2 class Net::Pcap
	
=begin code
is repr('CPointer')

Implements `pcap_t`.
=end code


    
# Functions
my sub pcap_open_offline(Str $fname, OpaquePointer $errbuf)
    returns Pcap
    is native('libpcap') { * };
my sub pcap_create(Str $source, OpaquePointer $errbuf)
    returns Pcap
    is native('libpcap') { * };
my sub pcap_activate(Pcap $p)
    returns int
    is native('libpcap') { * };
my sub pcap_open_dead(int $linktype, int $snaplen)
    returns Pcap
    is native('libpcap') { * };
my sub pcap_close(Pcap $p)
    is native('libpcap') { * };

my sub pcap_geterr(Pcap $p)
    returns Str
    is native('libpcap') { * };

my sub pcap_next(Pcap $p, pcap_pkthdr_t $h)
    returns OpaquePointer
    is native('libpcap') { * };
my sub pcap_next_ex(Pcap $p, pcap_pkthdrp_t $pkt_header, u_charp_t $pkt_data)
    returns int
    is native('libpcap') { * };

my sub pcap_compile(Pcap $p, bpf_program_t $fp, Str $str, int $optimize, int32 $netmask)
    returns int
    is native('libpcap') { * };
my sub pcap_setfilter(Pcap $p, bpf_program_t $fp)
    returns int
    is native('libpcap') { * };
my sub pcap_freecode(bpf_program_t $fp)
    is native('libpcap') { * };

my sub pcap_findalldevs(pcap_ifp_t $alldevsp, OpaquePointer $errbuf)
    returns int
    is native('libpcap') { * };
my sub pcap_freealldevs(pcap_if_t $alldevs)
    is native('libpcap') { * };



=head3 Methods

=begin code
.create(Str $source="any") returns Net::Pcap
  Constructor for Net::Pcap for live-capturing, uses pcap_create(). Use .activate() on it.
=end code

method create(Str $source="any") returns Pcap {
    my $errbuf = C_Buf.calloc(256);
    my $r = pcap_create($source, $errbuf.ptr);
    if !defined($r) {
	my $err = $errbuf.Buf().decode('ascii');
	die("Pcap->create: ", $err);
    }
    return $r;
}



=begin code
.open_offline(Str $fname) returns Net::Pcap
  Constructor for Net::Pcap to open capture files, uses pcap_open_offline().
=end code

method open_offline(Str $fname) returns Pcap{
    my $errbuf = C_Buf.calloc(256);
    my $r = pcap_open_offline($fname, $errbuf.ptr);
    if !$r {
	my $err = $errbuf.Buf().decode('ascii');
	die("Pcap->open_offline: ", $err);
    }
    # TODO: Do I have to call free on $errbuf explicitly or does the GC call its DESTROY()?
    $r;
};



=begin code
.open_dead(Int $linktype, Int $snaplen) returns Net::Pcap
  Constructor for creating a fake Net::Pcap.
=end code

method open_dead(Int $linktype, Int $snaplen) returns Pcap {
    my $r = pcap_open_dead($linktype, $snaplen);
    if !$r {
	die("Pcap->open_dead: Cannot open dead pcap");
    }
    $r;
}



=begin code
.close()
  Calls pcap_close().
=end code

method close() {
    pcap_close(self);
};



=begin code
.activate()
  Activates the capture devices, uses pcap_activate().
=end code

method activate() {
    my $r = pcap_activate(self);

    die("Pcap->activate: warning: ", pcap_geterr(self)) if $r == 1;
    die("Pcap->activate: warning promiscuous mode not supported by device: ", pcap_geterr(self)) if $r == 2;
    die("Pcap->activate: warning tstamp type not supported by device") if $r == 3;
    die("Pcap->activate: error: ", pcap_geterr(self)) if $r == 0xFFFFFFFF;
    die("Pcap->activate: error has already been activated") if $r == 0xFFFFFFFF-3;
    die("Pcap->activate: error capture source does not exist: ", pcap_geterr(self)) if $r == 0xFFFFFFFF-4;
    die("Pcap->activate: error no permission to open capture source: ", pcap_geterr(self)) if $r == 0xFFFFFFFF-7;
    die("Pcap->activate: error no permission to put capture source in promiscuous mode") if $r == 0xFFFFFFFF-10;
    die("Pcap->activate: error monitor mode is not supported by capture source") if $r == 0xFFFFFFFF-5;
    die("Pcap->activate: error capture source is not up") if $r == 0xFFFFFFFF-8;
    die("Pcap->activate: unexpected error code") if $r != 0;
}



=begin code
.next() returns Parcel
  Get next frame.
  
  *Usage of .next_ex() is preferred due to better error messages!*
  
  Returns a parcel with two elements:
  - Net::Pcap::pcap_pkthdr_t structure
  - Net::Pcap::C_Buf containing the frame.
  Uses pcap_next().
=end code

method next() returns Parcel {
    my $hdr = pcap_pkthdr_t.new();
    my $ptr = pcap_next(self, $hdr) or die("Pcap->next: no more packets or error occurred");
    die("Pcap->next: caplen can never be larger than len") if $hdr.caplen > $hdr.len;

    my $cbuf = C_Buf.new($ptr, $hdr.caplen, False);
    ($hdr.clone(), $cbuf.clone());
};



=begin code
.next_ex() returns Parcel
  Get next frame.
  
  Returns a parcel with two elements:
  - Net::Pcap::pcap_pkthdr_t structure
  - Net::Pcap::C_Buf containing the frame.
  Uses pcap_next_ex().
=end code

method next_ex() returns Parcel {
    my $hdrp = pcap_pkthdrp_t.new();
    my $datap = u_charp_t.new();
    my $r = pcap_next_ex(self, $hdrp, $datap);
    die("Pcap->next_ex: timeout expired") if $r == 0;
    die("Pcap->next_ex: error while reading packet: ", pcap_geterr(self)) if $r == 0xFFFFFFFF;
    die("Pcap->next_ex: no more packets to read from file") if $r == 0xFFFFFFFE;
    die("Pcap->next_ex: unexpected return value: 0x", $r.base(16), "($r)") if $r != 1;

    my $cbuf = C_Buf.new($datap.u_char, $hdrp.hdr.caplen, False);
    ($hdrp.hdr.clone(), $cbuf.clone());
};



=begin code
.filter(Str $str, Int $optimize = 0, Int $netmask = 0xFFFFFFFF)
  Apply filter $str.

  Calls pcap_compile(), pcap_freecode() and pcap_setfilter().
=end code

method filter(Str $str, Int $optimize = 0, Int $netmask = 0xFFFFFFFF) {
    my $fp = bpf_program_t.new();
    my $r = pcap_compile(self, $fp, $str, $optimize, $netmask);
    LEAVE {pcap_freecode($fp) if defined($fp); }
    die("Pcap->filter(pcap_compile): failure: ", pcap_geterr(self)) if $r != 0;

    $r = pcap_setfilter(self, $fp);
    die("Pcap->filter(pcap_setfilter): failure: ", pcap_geterr(self)) if $r != 0;
}



=begin code
.findalldevs() returns Array
  Find all available capture devices. Uses pcap_findalldevs().

  Returns an array of hashes, each hash contains the keys:
  - name
  - description
  - flags
=end code

method findalldevs() returns Array {
    my $errbuf = C_Buf.calloc(256);
    my $devsp = pcap_ifp_t.new();
    my $r = pcap_findalldevs($devsp, $errbuf.ptr);
    #	LEAVE {if defined($devsp.if) {pcap_freealldevs($devsp.if);} }
    die("Pcap->findalldevs: ", $errbuf.Buf().decode('ascii')) if $r != 0;
    # TODO: Do I have to call free on $errbuf explicitly or does the GC call its DESTROY()?

    my @devs;
    if defined($devsp.if) {
	my $dev = $devsp.if;
	loop {
	    my $name = $dev.name // "";
	    my $description = $dev.description // "";
	    my $flags = $dev.flags;
	    @devs.push: {:$name, :$description, :$flags};
	    
	    last if !defined($dev.next);
	    $dev = $dev.next;
	};
    }
    
    @devs;
}
