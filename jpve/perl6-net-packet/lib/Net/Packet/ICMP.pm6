use Net::Packet :util;
use Net::Packet::Base :short;

=NAME
Net::Packet::ICMP

=begin SYNOPSIS
    use Net::Packet::ICMP :short;

    my $frame = Buf.new([...]);
    my $icmp = ICMP.decode($frame);

    # New ping request:
    my $icmp = ICMP.new(:type(8), :code(0));
    $icmp.id = 0xCAFE;
    $icmp.sequence_number = 0xBEEF;
=end SYNOPSIS

=begin EXPORTS
    class Net::Packet::ICMP

:short trait adds export:

    constant ICMP ::= Net::Packet::ICMP
=end EXPORTS

=DESCRIPTION

=head2 class Net::Packet::ICMP
=begin code
is Net::Packet::Base
=end code

class Net::Packet::ICMP is Base;

my constant ICMP is export(:short) ::= Net::Packet::ICMP;



=head3 Attributes

=begin code
$.type    is rw is Int
$.code    is rw is Int
$.chksum  is rw is Int
  ICMP type/code/checksum field.

$.hdr     is rw
  Rest-of-header, four bytes fields. Contents vary based on ICMP type and code.
  can either be of builtin type Buf, or C_Buf (from Net::Pcap).
=end code

has Int $.type is rw;
has Int $.code is rw;
has Int $.chksum is rw;
has $.hdr is rw;

has Base $!payload;



=head3 Methods



#method BUILD() {
#    $.hdr = Buf.new([0x00, 0x00, 0x00, 0x00]);
#}

=begin code
.decode($frame, Net::Packet::Base $parent?) returns Net::Packet::ICMP
  Returns the ICMP packet corresponding to $frame.
=end code

method decode($frame, Base $parent?) {
    if defined($parent) {
	return self.new(:$frame, :$parent)._decode();
    }
    self.new(:$frame)._decode();
}

method _decode() {
    $.type = $.frame[0];
    $.code = $.frame[1];
    $.chksum = unpack_n($.frame,2);
    $.hdr = $.frame.subbuf(4, 4);
    $.data = $.frame.subbuf(8)
	if $.frame.elems > 8;
    self;
}



=begin code
.id() returns Proxy is rw
  Returns a Proxy for the identifier of this packet. Only valid for specific
  combinations of $.type and $.code, as per ICMP specification, else it dies.
  Usage:
    $icmp.id = ...
    my $id = $eth.id.
=end code

method id() is rw {
    die("Cannot get/set identifier field in header for this combination of \$.type ($.type) and \$.code ($.code)")
	if !($.code == 0 && ($.type ~~ (0, 8).any));
    Proxy.new(
	FETCH => {
	    unpack_n($.frame, 4);
	},
	STORE => -> $id {
	    die("Cannot set identifier field in header: invalid value")
		if !(0 <= $id <= 2**16-1);
	    $.frame[4] = $id +> 8;
	    $.frame[5] = $id +& 0xFF;
	}
    );
}



=begin code
.sequence_number() returns Proxy is rw
  Returns a Proxy for the sequence number of this packet. Only valid for specific
  combinations of $.type and $.code, as per ICMP specification, else it dies.
  Usage:
    $icmp.sequence_number = ...
    my $id = $eth.sequence_number.
=end code

method sequence_number() is rw {
    die("Cannot get/set sequence number field in header for this combination of \$.type ($.type) and \$.code ($.code)")
	if !($.code == 0 && ($.type ~~ (0, 8).any));
    Proxy.new(
	FETCH => {
	    unpack_n($.frame, 6);
	},
	STORE => -> $id {
	    die("Cannot set sequence number field in header: invalid value")
		if !(0 <= $id <= 2**16-1);
	    $.frame[6] = $id +> 8;
	    $.frame[7] = $id +& 0xFF;
	}
    );
}

