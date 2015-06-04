use Net::Packet :util;
use Net::Packet::Base :short;

=NAME
Net::Packet::UDP

=begin SYNOPSIS
    use Net::Packet::UDP :short;

    my $buf = Buf.new([...]);
    my $udp = UDP.decode($buf);

    say sprintf '%d -> %d: %d\n',
        $udp.src_port, $udp.dst_port, $udp.length;

Prints '53 -> 49875: 90'
=end SYNOPSIS

=begin EXPORTS
    Net::Packet::UDP

:short trait adds exports:

    constant UDP ::= Net::Packet::UDP;
=end EXPORTS

=begin DESCRIPTION
Net::Packet::UDP takes a byte buffer and returns a corresponding packet object.
The byte buffer can be of the builtin Buf type or the C_Buf type of Net::Pcap.
=end DESCRIPTION

=head2 class Net::Packet::UDP
=begin code
is Net::Packet::Base
=end code

unit class Net::Packet::UDP is Net::Packet::Base;

my constant UDP is export(:short) ::= Net::Packet::UDP;



=head3 Attributes

=begin code
$.src_port  is rw is Int
$.dst_port  is rw is Int
  Source/Destination port fields.

$.length    is rw is Int
  Packet length in bytes including header and data.

$.chksum    is rw is Int
  Checksum field for erro checking of the header and data.

$.data      is rw is Buf/C_Buf
  UDP data following the UDP header. Type is the same as the $frame given to .decode().
=end code

has Int $.src_port is rw;
has Int $.dst_port is rw;
has Int $.length is rw;
has Int $.chksum is rw;


=head3 Methods

=begin code
.decode($frame, Net::Packet::Base $parent?) returns Net::Packet::UDP
  Returns the UDP packet corresponding to $frame.
=end code

multi method decode($frame) returns UDP {
    self.new(:$frame)._decode();
}

multi method decode($frame, Net::Packet::Base $parent) returns UDP {
    self.new(:$frame, :$parent)._decode();
}

method _decode() returns UDP {
    ## Optimized version of:
    # ($.src_port, $.dst_port, $.length, $.chksum) = $.frame.unpack('nnnn');
    $.src_port = unpack_n($.frame, 0);
    $.dst_port = unpack_n($.frame, 2);
    $.length   = unpack_n($.frame, 4);
    $.chksum   = unpack_n($.frame, 6);
    
    $.data = $.frame.subbuf(8);

    # TODO: check checksum.
    self;
}

method encode() {
    die('UDP.encode: data is too large') if $.data.elems > 2**16;
    $.length = $.data.elems;

    my $dbuf = $.data.WHICH eq 'C_Buf' ?? $.data.Buf !! $.data;
    $.frame = pack('nnnn', $.src_port, $.dst_port, $.length, $.chksum) ~ $dbuf;

    $.frame;
}

