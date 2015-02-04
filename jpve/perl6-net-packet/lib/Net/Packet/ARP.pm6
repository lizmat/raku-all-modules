use Net::Packet :util;
use Net::Packet::Base      :short;
use Net::Packet::IPv4_addr :short;
use Net::Packet::MAC_addr  :short;
use Net::Packet::EtherType :short;

=NAME
Net::Packet::ARP - Interface for decoding ARP packets.

=begin SYNOPSIS
    use Net::Packet::ARP :short;

    my $frame = Buf.new([...]);
    my $arp = ARP.decode($frame);

    say sprintf '%s(%s) -> %s(%s): %s',
        $arp.src_hw_addr.Str, $arp.src_proto_addr.Str,
        $arp.dst_hw_addr.Str, $arp.dst_proto_addr.Str,
        $arp.operation;
	    
Prints '66:77:88:99:AA:BB(102.119.136.153) -> 00:11:22:33:44:55(0.17.34.51): Request'
=end SYNOPSIS

=begin EXPORTS
    Net::Packet::ARP
    Net::Packet::ARP::HardwareType
    Net::Packet::ARP::Operation

:short trait adds exports:

    constant ARP               ::= Net::Packet::ARP
    # Implies:
             ARP::HardwareType ::= Net::Packet::ARP::HardwareType
             ARP::Operation    ::= Net::Packet::ARP::Operation
=end EXPORTS

=begin DESCRIPTION
Net::Packet::ARP takes a byte buffer and returns a corresponding packet object.
The byte buffer can be of the builtin Buf type or the C_Buf type of Net::Pcap.
=end DESCRIPTION

=head2 enum Net::Packet::ARP::HardwareType
=begin code
Type to describe the hardware type field of an ARP packet.
=end code

module Net::Packet::ARP::HardwareType {
    enum Net::Packet::ARP::HardwareType (
	Ethernet => 0x0001,
    );
}

# TODO: Add how to use ARP::HardwareType to USAGE section



=head2 enum Net::Packet::ARP::Operation
=begin code
Type to describe the operation field of an ARP packet.
=end code

module Net::Packet::ARP::Operation {
    enum Net::Packet::ARP::Operation (
	Request  => 0x0001,
        Response => 0x0002,
    );
}

# TODO: Add how to use ARP::Operation to USAGE section



=head2 class Net::Packet::ARP
=begin code
is Net::Packet::Base
=end code
    
class Net::Packet::ARP is Base {
    my constant ARP is export(:short) ::= Net::Packet::ARP;
    my constant HardwareType ::= Net::Packet::ARP::HardwareType;
    my constant Operation ::= Net::Packet::ARP::Operation;



=head3 Attributes
=begin code
 $.hw_type         is rw is Net::Packet::ARP::HardwareType
  Hardware address type field

$.proto_type      is rw is Net::Packet::EtherType
  Protocol address type field

$.hw_len          is rw is Int
  Hardware address length field

$.proto_len       is rw is Int
  Protocol address length field

$.operation       is rw is Net::Packet::ARP::Operation
  Operation field
   
$.src_hw_addr     is rw
$.dst_hw_addr     is rw
$.src_proto_addr  is rw
$.dst_proto_addr  is rw
  Sender/Receiver hardware/protocol address fields. Typed with the type
  of address (eg. Net::Packet::IPv4, Net::Packet::MAC_addr).
=end code



    has HardwareType $.hw_type is rw;    # Hardware type
    has EtherType    $.proto_type is rw; # Protocol type
    
    has Int $.hw_len is rw;     # Hardware address length
    has Int $.proto_len is rw;  # Protocol address length
    
    has Operation $.operation is rw;  # Operation

    has $.src_hw_addr is rw;    # Sender hardware address
    has $.dst_hw_addr is rw;    # Target hardware address

    has $.src_proto_addr is rw; # Sender protocol address
    has $.dst_proto_addr is rw; # Target protocol address

=head3 Methods
=begin code
.decode($frame, Net::Packet::Base $parent?) returns Net::Packet::ARP
  Returns the ARP packet corresponding to $frame.
=end code

    multi method decode($frame, Net::Packet::Base $parent?) returns ARP {
	if defined($parent) {
	    return self.new(:$frame, :$parent)._decode();
	}
	self.new(:$frame)._decode();
    }

    method _decode() returns ARP {
	die("ARP.decode: frame too small") if $.frame.elems < 8;
	
	$.hw_type     = HardwareType(unpack_n($.frame, 0));
	$.proto_type  = EtherType(unpack_n($.frame, 2));
	$.hw_len      = $.frame[4];
	$.proto_len   = $.frame[5];
	$.operation   = ARP::Operation(unpack_n($.frame, 6));

	my Int $len = 8;

	if $.hw_type == HardwareType::Ethernet {
	    $.src_hw_addr = MAC_addr.unpack($.frame, $len);
	    $.dst_hw_addr = MAC_addr.unpack($.frame, $len+$.hw_len+$.proto_len);
	}
	else {
	    die(sprintf("ARP.decode: Hardware type (%d) not implemented\n", $.hw_type));
	}

	if $.proto_type == EtherType::IPv4 {
	    $.src_proto_addr = IPv4_addr.unpack($.frame, $len+$.hw_len);
	    $.dst_proto_addr = IPv4_addr.unpack($.frame, $len+$.hw_len+$.proto_len+$.hw_len);
	}
	else {
	    die(sprintf("ARP.decode: Hardware type (%d) not implemented\n", $.proto_type));
	}

	self;	    
    }


=begin code
.encode()
  Writes to packet to the $.frame buffer.
=end code

    method encode() {
	die("Protocol type not supported") if $.proto_type != EtherType::IPv4;

	given $.hw_type.value {
	    when HardwareType::Ethernet.value {
		$.hw_len = 6;
		die("\$.src_hw_addr is of incorrect type, should correspond to \$.hw_type")
		    unless $.src_hw_addr ~~ MAC_addr;
		die("\$.dst_hw_addr is of incorrect type, should correspond to \$.hw_type")
		    unless $.dst_hw_addr ~~ MAC_addr;
	    }
	    default {
		die("Hardware type not supported") if $.hw_type != HardwareType::MAC_addr;
	    }
	}

	given $.proto_type.value {
	    when EtherType::IPv4.value {
		$.proto_len = 4;
		die("\$.src_proto_addr is of incorrect type, should correspond to \$.proto_type")
		    unless $.src_proto_addr ~~ IPv4_addr;
		die("\$.dst_proto_addr is of incorrect type, should correspond to \$.proto_type")
		    unless $.dst_proto_addr ~~ IPv4_addr;
	    }
	    default {
		die("Protocol type not supported") if $.hw_type != HardwareType::MAC_addr;
	    }
	}

	my Buf $hdr = pack('nnCCn',
	    $.hw_type.value,
	    $.proto_type.value,
	    $.hw_len, $.proto_len,
	    $.operation.value
	);

	$hdr ~= $.src_hw_addr.Buf;
	$hdr ~= $.src_proto_addr.Buf;
	$hdr ~= $.dst_hw_addr.Buf;
	$hdr ~= $.dst_proto_addr.Buf;

	$.frame = $hdr;
    }
}

    
