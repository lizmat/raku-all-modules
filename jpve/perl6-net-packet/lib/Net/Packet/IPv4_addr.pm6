use Net::Packet :util;


=NAME
Net::Packet::IPv4_addr

=begin SYNOPSIS
    use IPv4_addr :short;

    my $buf = Buf.new([0, 11, 22, 33, 44, 55]);
    my $ip  = IPv4_addr.unpack($buf, 1); # Starts unpacking at $buf[1].

    say $ip.Str; '11.22.33.44'
=end SYNOPSIS

=begin EXPORTS
    Net::Packet::IPv4_addr;

:short traits adds export:

    constant IPv4_addr ::= Net::Packet::IPv4_addr;
=end EXPORTS

=DESCRIPTION

=head2 class Net::Packet::IPv4_addr

class Net::Packet::IPv4_addr;

my constant IPv4_addr is export(:short) ::= Net::Packet::IPv4_addr;



=head3 Attributes

=begin code
 $.addr  is rw is Int
   Address
=end code

has Int $.addr is rw = 0;



=head3 Methods

=begin code
.new(Int $addr) returns IPv4_addr
.new(Str $addr) returns IPv4_addr
  Constructor, takes $addr as:
   - Int;
   - Str in the form of '1.222.33.44'.
=end code

multi method new(Int $addr) returns IPv4_addr {
    self.bless(:$addr);
}

multi method new(Str $addr) returns IPv4_addr {
    die("IPv4_addr.new: Invalid string format")
	unless $addr ~~ / (\d**1..3 '.')**3  \d**1..3 /;
	my @shifts = 24, 16, 8, 0;
    self.bless(:addr([+] $addr.split('.').map({.Int +< shift(@shifts)})));
}


=begin code
.unpack($buf, Int $i) returns IPv4_addr
  Constructor, unpacks address from buffer $buf starting at position $i.
  $buf can be of builtin type Buf or C_Buf from Net::Pcap.
=end code

method unpack($buf, Int $i) returns IPv4_addr {
    self.new(unpack_N($buf, $i));
}



=begin code
.octets() returns Array
  Returns the address represented by an Array of 4 Ints (one for each byte of
  the address).
=end code

method octets() returns Array {
    my @octs;
    @octs.push:  $.addr +> 24;
    @octs.push: ($.addr +> 16) +& 0xFF;
    @octs.push: ($.addr +> 8)  +& 0xFF;
    @octs.push:  $.addr +& 0xFF;
    @octs;
}



=begin code
.Int() returns Int
  Returns the address as Int.
=end code

method Int returns Int {
    $.addr;
}



=begin code
.Str() returns Str
  Returns the address as string in the form of '11.22.33.44'.
=end code

method Str returns Str {
    my @octs = self.octets();
    sprintf('%d.%d.%d.%d', |@octs);
}



=begin code
.Buf() returns Buf
  Returns the address as a byte string.
=end code

method Buf returns Buf {
    Buf.new(|self.octets());
}
