# Net::Pcap (Perl6)

Libpcap bindings for Perl6.

The modules are annotated with Pod. These Pods are rendered to [docs/](/docs).

[perl6-net-packet](https://github.com/jpve/perl6-net-packet) is useful for decoding frames.

## Installation

Using panda:
```
$ panda update
$ panda install Net::Pcap
```

Using ufo:
```
$ ufo           # Generates Makefile
$ make
$ make test
$ make install
```

## Usage

Starting a capture:
```
use Net::Pcap;

# Live capturing
my $pcap = Net::Pcap.create("eth0");
$pcap.filter('portrange 1-1024');
$pcap.activate;

# Read from file
my $pcap = Net::Pcap.offline_open('./capture.pcap');
```

Looping through frames:

```
use Net::Packet :short;

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
```
