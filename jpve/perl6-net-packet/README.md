# Net::Packet (Perl6)

Perl6 module for decoding network packets. Encoding/Generating packets is on the TODO list.

The modules are written in pure Perl6. Both the `Buf` and the `C_Buf` class can be used as frames to decode. (`C_Buf` from the perl6-net-pcap module).

The following protocols are implemented: Ethernet, IPv4, UDP and ARP. Each protocol has its own module `Net::Packet::*`.

## Documentation

All modules are documented using in-file Pod. The in-file Pods are rendered to Markdown formatted files in the [docs/](/docs) directory.

## Installation

Using panda:
```
$ panda update
$ panda install Net::Packet
```

Using ufo:
```
$ ufo          # Generates Makefile
$ make
$ make test
$ make install
```

## Usage:

```
use Net::Packet::Ethernet :short; # use :short for short notation:
use Net::Packet::IPv4 :short;     #   Ethernet.decode
use Net::Packet::UDP :short;      # instead of
                                  #   Net::Packet::Ethernet.decode

my $pkt = Buf.new([...]);

my $eth = Ethernet.decode($pkt);
printf "%s -> %s: ", $eth.src.Str, $eth.dst.Str;
# use .Str or .Int to convert .src/.dst to something usable.

my $ip  = IPv4.decode($eth.data, $eth);
printf "%s -> %s: ", $ip.src.Str, $ip.src.Str;

my $udp = UDP.decode($ip.data, $ip);
printf "%d -> %d\n", $udp.src_port, $udp.dst_port;
```

```
use Net::Ethernet :short;

my $pkt = Buf.new([...]);

my $eth = Ethernet.decode($pkt);
printf "%s -> %s: ", $eth.src.Str, $eth.dst.Str;

if $eth.pl ~~ IPv4 { # .pl (for PayLoad) decodes the payload
   printf "%s -> %s: ", $eth.pl.src.Str, $eth.pl.dst.Str;
      
   if $eth.pl.pl ~~ UDP {
      printf "%d -> %d: ", $eth.pl.pl.src_port, $eth.pl.pl.dst_port;
   }
}
```

