=NAME
Net::Packet - Decoding network frames/packets.

=begin SYNOPSIS

=for comment
Needed to comment out the `use` statements, else panda thinks these are dependencies.

=begin code
# use Net::Packet::Ethernet :short;
# use Net::Packet::IPv4 :short;
# use Net::Packet::UDP :short;

my $pkt = Buf.new([...]);

my $eth = Ethernet.decode($pkt);
printf "%s -> %s: ", $eth.src.Str, $eth.dst.Str;

my $ip  = IPv4.decode($eth.data, $eth);
printf "%s -> %s: ", $ip.src.Str, $ip.src.Str;

my $udp = UDP.decode($ip.data, $ip);
printf "%d -> %d\n", $udp.src_port, $udp.dst_port;
=end code

Prints '11:22:33:AA:BB:CC -> 44:55:66:EE:DD:FF: 11.22.33.44 -> 55.66.77.88: 443 -> 49875'. Following code prints the same:

=begin code
# use Net::Ethernet :short;

my $pkt = Buf.new([...]);

my $eth = Ethernet.decode($pkt);
printf "%s -> %s: ", $eth.src.Str, $eth.dst.Str;

if $eth.pl ~~ IPv4 { # .pl (for PayLoad) decodes the payload
   printf "%s -> %s: ", $eth.pl.src.Str, $eth.pl.dst.Str;

   if $eth.pl.pl ~~ UDP {
      printf "%d -> %d\n", $eth.pl.pl.src_port, $eth.pl.pl.dst_port;
   }
}
=end code

=end SYNOPSIS

=begin EXPORTS
    use Net::Packet :util;

exports:

    sub unpack_n(); # See description
    sub unpack_N(); # See description
=end EXPORTS

=DESCRIPTION

=head2 module Net::Packet

module Net::Packet;

=head3 Subroutines

=begin code
unpack_n($buf, Int $i) returns Int
  Decodes a 16-bit integer from $buf, starting at $buf[$i].
=end code

my sub unpack_n($buf, Int $i) returns Int is export(:util) {
    return ($buf[$i] +< 8) + $buf[$i+1];
}


=begin code
unpack_N($buf, Int $i) returns Int
  Decodes a 32-bit integer from $buf, starting at $buf[$i].
=end code

my sub unpack_N($buf, Int $i) returns Int is export(:util) {
    return ($buf[$i] +< 24) + ($buf[$i+1] +< 16) + ($buf[$i+2] +< 8) + $buf[$i+3];
}

