use Net::Packet :util;
use Net::Packet::Base :short;
use Net::Packet::IPv4_addr;
use Net::Packet::IP_proto;
use Net::Packet::UDP  :short;
use Net::Packet::ICMP :short;

=NAME
Net::Packet::IPv4

=begin SYNOPSIS
    use Net::Packet::IPv4 :short;

    my $frame = Buf.new([...]);
    my $ip = IPv4.new($frame);

    say sprintf '%s -> %s: %s',
        $ip.src.Str, $ip.dst.Str, $ip.proto;
=end SYNOPSIS

=begin EXPORTS
    Net::Packet::IPv4

:short trait adds exports:

    constant IPv4       ::= Net::Packet::IPv4;
    constant IPv4_addr  ::= Net::Packet::IPv4_addr;
    constant IP_proto   ::= Net::Packet::IP_proto;
=end EXPORTS

=begin DESCRIPTION
Net::Packet::IPv4 takes a byte buffer and returns a corresponding packet object.
The byte buffer can be of the builtin Buf type or the C_Buf type of Net::Pcap.
=end DESCRIPTION

=head2 class Net::Packet::IPv4
=begin code
is Net::Packet::Base
=end code
    
class Net::Packet::IPv4 is Net::Packet::Base;
    
my constant IPv4 is export(:short) ::= Net::Packet::IPv4;
my constant IPv4_addr is export(:short) ::= Net::Packet::IPv4_addr;
my constant IP_proto  is export(:short) ::= Net::Packet::IP_proto;




=head3 Attributes

=begin code
 $.src              is rw is Net::Packet::IPv4_addr
$.dst              is rw is Net::Packet::IPv4_addr
  Source/destination ip address field.

$.proto            is rw is Net::Packet::IP_proto
  Protocol field. 

$.id               is rw is Int
$.fragment_offset  is rw is Int
$.flags            is rw is Int
  Identification/Fragment offset/Flags field. All these things
  control fragmentation of IP packets.

$.ihl              is rw is Int
  Internet Header Length field. Used to specify length of the header.
  IPv4 has extra field for options (option fields are NOT YET
  IMPLEMENTED)
  
$.dscp             is rw is Int
$.ecn              is rw is Int
  DSCP/ECN field.  

$.total_length     is rw is Int
  Total length of packet (fragment) size including header and payload in
  bytes.

$.ttl              is rw is Int
  Time To Live field. Helps prevent datagrams from going in circles. It
  limits the datagrams lifetime.

$.hdr_chksum       is rw is Int
  Header checksum field.
=end code 

has Int $.ihl is rw;
has Int $.dscp is rw;
has Int $.ecn is rw;
has Int $.total_length is rw;
has Int $.id is rw;
has Int $.flags is rw;
has Int $.fragment_offset is rw;
has Int $.ttl is rw;
has IP_proto $.proto is rw;
has Int $.hdr_chksum is rw;
has Net::Packet::IPv4_addr $.src is rw;
has Net::Packet::IPv4_addr $.dst is rw;

has Base $!payload;



=head3 Methods

=begin code
.decode($frame, Net::Packet::Base $parent?) returns Net::Packet::IPv4
  Returns the IPv4 packet corresponding to $frame.
=end code

multi method decode($frame) returns IPv4 {
    my $s = self.new(:$frame);
    $s._decode();
}

multi method decode($frame, Base $parent) returns IPv4 {
    self.new(:$frame, :$parent)._decode();
}

method _decode() returns IPv4 {
    die("IPv4.decode: frame too small") if $.frame.elems < 20;

    my $version =            $.frame[0] +> 4;
    die("IPv4.decode: version field is not 4") if $version != 4;

    $.ihl =               $.frame[0] +& 0x0F;
    $.dscp =              $.frame[1] +> 2;
    $.ecn =               $.frame[1] +& 0x03;
    $.total_length =     ($.frame[2] +< 8) + $.frame[3];
    $.id =               ($.frame[4] +< 8) + $.frame[5];
    $.flags =             $.frame[6] +> 5;
    $.fragment_offset = (($.frame[6] +& 0x1F) +< 8) + $.frame[7];
    $.ttl =               $.frame[8];
    $.proto =             Net::Packet::IP_proto($.frame[9]);
    $.hdr_chksum =       ($.frame[10] +< 8) + $.frame[11];
    $.src = Net::Packet::IPv4_addr.unpack($.frame, 12);
    $.dst = Net::Packet::IPv4_addr.unpack($.frame, 16);

    # TODO: Do we want to check the chksum?
    # TODO: IPv4 has option fields, not yet implemented.

    if $.frame.elems > 20 {
	$.data = $.frame.subbuf($.ihl*4);
    }
    
    self;
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
		
	    if    $.proto == IP_proto::UDP.value {
		$!payload = UDP.decode($.data, self);
	    }
	    elsif $.proto == IP_proto::ICMP.value {
		$!payload = ICMP.decode($.data, self);
	    }
	    
	    $!payload;
	},
	STORE => -> $pl {
	    my IP_proto $proto;

	    $proto = IP_proto::UDP  if $pl ~~ UDP;
	    $proto = IP_proto::ICMP if $pl ~~ ICMP;

	    $.proto = $proto;
	    $!payload = $pl;
	}
    );
}

