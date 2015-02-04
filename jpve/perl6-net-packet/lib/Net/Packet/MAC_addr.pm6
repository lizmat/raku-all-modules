use Net::Packet :util;

=NAME
Net::Packet::MAC_addr - Decode and format MAC addresses.

=begin SYNOPSIS
    use Net::Packet::MAC_addr :short;

    my $buf = Buf.new([0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77]);
    my $mac = MAC_addr.unpack($buf, 1); # Start unpacking at $buf[1].
    say $mac.Str; # '11:22:33:44:55:66'

    my $mac = MAC_addr.new(0x112233AABBCC);
    say $mac.Str; # '11:22:33:AA:BB:CC'
=end SYNOPSIS

=begin EXPORTS
    Net::Packet::MAC_addr

:short trait adds export:

    constant MAC_addr ::= Net::Packet::MAC_addr
=end EXPORTS	

=DESCRIPTION

=head2 class Net::Packet::MAC_addr

class Net::Packet::MAC_addr;

my constant MAC_addr is export(:short) ::= Net::Packet::MAC_addr;



=head3 Attributes

=begin code
 $.addr  is rw is Int
   Address
=end code

has Int $.addr is rw = 0;



=head3 Methods

=begin code
.new(Int $addr) returns MAC_addr
.new(Str $addr) returns MAC_addr
  Constructor, takes $addr:
   - Int;
   - Str in the form of '00:11:22:AA:BB:CC'.
=end code

multi method new(Int $addr) returns MAC_addr {
    self.bless(:$addr);
}

multi method new(Str $addr) returns MAC_addr {
    die('MAC_addr.new: Invalid string format')
	unless $addr ~~ /^(<[0..9 A..F a..f]>**2\:)**5 <[0..9 A..F a..f]>**2$/;
    self.bless(:addr(('0x'~$addr.subst(':', '', :g)).Int));
}



=begin code
.unpack($buf, Int $i) returns MAC_addr
  Constructor, unpacks address from buffer $buf starting at position $i.
  $buf can be of builtin type Buf or C_Buf from Net::Pcap.
=end code

method unpack($buf, Int $i) returns MAC_addr {
    my Int $hi  = unpack_N($buf, $i);
    my Int $low = unpack_n($buf, $i+4);
	
    MAC_addr.new(($hi +< 16) + $low);
}



=begin code
.octets() returns Array
  Returns the address represented by an Array of 6 Ints (one for each byte of
  the address).
=end code

method octets() returns Array {
    my @octs;
    @octs.push:  $.addr +> 40;
    @octs.push: ($.addr +> 32) +& 0xFF;
    @octs.push: ($.addr +> 24) +& 0xFF;
    @octs.push: ($.addr +> 16) +& 0xFF;
    @octs.push: ($.addr +>  8) +& 0xFF;
    @octs.push:  $.addr +& 0xFF;
    @octs;
}



=begin code
.Int() returns Int
  Returns the address as Int.
=end code

method Int() returns Int {
    $.addr;
}



=begin code
.Str() returns Str
  Returns the address as string in the form of '00:11:22:AA:BB:CC'.
=end code

method Str() returns Str {
    my @octs = self.octets();
    sprintf('%02X:%02X:%02X:%02X:%02X:%02X', |@octs);
}



=begin code
.Buf() returns Buf
  Returns the address as a byte string.
=end code

method Buf() returns Buf {
    Buf.new(|self.octets);
}
