use Net::Packet :util;
use Net::Packet::Base :short;
use Net::Packet::MAC_addr;
use Net::Packet::EtherType;
use Net::Packet::IPv4;
use Net::Packet::ARP;

=NAME
Net::Packet::Ethernet
    
=begin SYNOPSIS
    use Net::Packet::Ethernet :short;

    my $frame = Buf.new([...]);
    my $eth = Ethernet.decode($frame);

    say sprintf '%s -> %s: %s',
        $eth.src.Str, $eth.src.Str, $eth.type;

Prints: 66:77:88:99:AA:BB -> 66:77:88:99:AA:BB: IPv4
	    
=end SYNOPSIS

# TODO: Add $eth.pl syntax to SYNOPSIS

=begin EXPORTS
    Net::Packet::Ethernet

:short trait adds exports:

    constant Ethernet  ::= Net::Packet::Ethernet;
    constant MAC_addr  ::= Net::Packet::MAC_addr;
    constnat EtherType ::= Net::Packet::EtherType;
=end EXPORTS
    
=begin DESCRIPTION
Net::Packet::Ethernet takes a byte buffer and returns a corresponding packet object.
The byte buffer can be of the builtin Buf type or the C_Buf type of Net::Pcap.
=end DESCRIPTION

=head2 class Net::Packet::Ethernet
=begin code
is Net::Packet::Base;
=end code

unit class Net::Packet::Ethernet is Base;

my constant Ethernet  is export(:short) ::= Net::Packet::Ethernet;
my constant MAC_addr  is export(:short) ::= Net::Packet::MAC_addr;
my constant EtherType is export(:short) ::= Net::Packet::EtherType;



=head3 Attributes
=begin code
 $.src         is rw is Net::Packet::Ethernet::MAC_addr
$.dst         is rw is Net::Packet::Ethernet::MAC_addr
  Source/destination MAC address

$.type        is rw is Net::Packet::Ethernet::EtherType
  Payload type.

$.is_802_1Q   is rw is Bool
  Set if packet is of type IEE802.1Q.
  
$.pcp         is rw is Int
$.dei         is rw is Int
$.vid         is rw is Int
  PCP/DEI/VID field. Only used if $.is_802_1Q is set.

$.is_802_1ad  is rw is Bool
  Set if packet is of type IEEE802.1ad.

$.s-vid       is rw is Int
$.s-dei       is rw is Int
$.s-pcp       is rw is Int
  PCP/DEI/VID field of the service provider. Only used if IEEE802.1ad is set.
=end code

has MAC_addr $.src is rw;
has MAC_addr $.dst is rw;
has EtherType $.type is rw;
has Base $!payload;

# 802.1ad frame specific values
has Bool $.is_8021ad is rw = False;
has Int $.s-pcp is rw; # Priority code point
has Int $.s-dei is rw; # Drop eligible indicator
has Int $.s-vid is rw; # VLAN indicator

# 802.1Q frame specific values
has Bool $.is_8021Q is rw = False;
has Int $.pcp is rw; # Priority code point
has Int $.dei is rw; # Drop eligible indicator
has Int $.vid is rw; # VLAN indicator



=head3 Methods

=begin code
.decode($frame, Net::Packet::Base $parent?) returns Net::Packet::Ethernet
  Returns the Ethernet packet corresponding to $frame.
=end code

multi method decode($frame) returns Ethernet {
    self.new(:$frame)._decode();
}

multi method decode($frame, Base $parent) returns Ethernet {
    self.new(:$frame, :$parent)._decode();
}

method _decode returns Ethernet {
    # TODO: unpack should handle this
    die("Ethernet.decode: frame too small") if $.frame.elems < 14;
    
    # Destination, source macs and type
    my Int $hdrlen = 12;
    ## Below optimized version of follows:
    # my Int ($dst_hi, $dst_low, $src_hi, $src_low) = $.frame.unpack('NnNn');
    # my Int $dst_hi  = unpack_N($.frame, 0);
    # my Int $dst_low = unpack_n($.frame, 4);
    # my Int $src_hi  = unpack_N($.frame, 6);
    # my Int $src_low = unpack_n($.frame, 10);

    # $.dst = MAC_addr.new(($dst_hi +< 16) + $dst_low);
    # $.src = MAC_addr.new(($src_hi +< 16) + $src_low);
    $.dst = MAC_addr.unpack($.frame, 0);
    $.src = MAC_addr.unpack($.frame, 6);

    # Begin very optimistic by assuming this is a 802.1ad frame
    ## Below optimized version of follows:
    # my ($s-tpid, $s-tci, $c-tpid, $c-tci, $type) = $.frame.subbuf(6+6,4+4+2).unpack('nnnnn');
    my Int $s-tpid = unpack_n($.frame, 12);
    my Int $s-tci  = unpack_n($.frame, 14);
    my Int $c-tpid = unpack_n($.frame, 16);
    my Int $c-tci  = unpack_n($.frame, 18);
    my Int $type   = unpack_n($.frame, 20);

    if $s-tpid == EtherType::IEEE802_1ad.value {
	# 802.1ad + 802.1Q frame
	$hdrlen += 4;
	$.is_802_1ad = True;
	$.s-pcp = $s-tci +> 13;
	$.s-dei = ($s-tci +> 12) +& 0x0001;
	$.s-vid = $s-tci +& 0x0FFF;
	die('Ethernet.decode: Customer TPID ('~$c-tpid.base(16)~') is incorrect') if $c-tpid != EtherType::IEEE802_1Q.value;
    }
    else {
	# 802.1ad frame assumption incorrect, now optimistic assumption of 802.1Q frame
	$type = $c-tpid;
	$c-tpid = $s-tpid;
	$c-tci = $s-tci;
    }
    
    if $c-tpid == EtherType::IEEE802_1Q.value {
	# 802.1Q frame
	$hdrlen += 4;
	$.is_802_1Q = True;
	$.pcp = $c-tci +> 13;
	$.dei = ($c-tci +> 12) +& 0x0001;
	$.vid = $c-tci +& 0x0FFF;
    }
    else {
	# 802.1Q assumption incorrect
	$type = $c-tpid;
    }

    $hdrlen += 2;
    $.type = EtherType($type);

    if $.frame.elems > $hdrlen {
	$.data = $.frame.subbuf($hdrlen);
    }

    self;
}



=begin code
.encode()
  Writes the packet to $.frame buffer, including the payload.
=end code

method encode() {
    $!payload.encode;

    if $!payload ~~ Net::Packet::ARP {
	$.type = EtherType::ARP;
    }
    else {
	die("Ethernet.encode: Payload not implemented");
    }
    
    # TODO: Adds support for encoding 802.1Q/ad fields
    my Buf $hdr =   $.dst.Buf 
                  ~ $.src.Buf
                  ~ pack('n', $.type.value);
    $.frame = $hdr ~ $!payload.frame;
}



=begin code
.pl() returns Proxy is rw
  Returns a Proxy for the payload of this packet.
  Usage:
    $eth.pl = ...
    my $ip = $eth.pl.
=end code

method pl() is rw {
    Proxy.new(
	FETCH => {
	    return $!payload if $!payload;

	    if    $.type == EtherType::IPv4.value {
		$!payload = Net::Packet::IPv4.decode($.data, self);
	    }
	    elsif $.type == EtherType::ARP.value {
                $!payload = Net::Packet::ARP.decode($.data, self);
	    }

	    $!payload;
	},
	STORE => -> $self, $pl {
	    my EtherType $type;
	    $type = EtherType::IPv4 if $pl ~~ Net::Packet::IPv4;
	    $type = EtherType::ARP  if $pl ~~ Net::Packet::ARP;

	    $.type = $type;
	    $!payload = $pl;
	}
    );
}

