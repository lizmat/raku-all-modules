=NAME
Net::Pcap::Linktype

=begin SYNOPSYS
    use Net::Pcap::Linktype :short;

    say Linktype::Ethernet.value;
=end SYNOPSYS

=begin EXPORTS
    enum Net::Pcap::Linktype;

:short trait adds exports:

    constant Linktype ::= Net::Pcap::Linktype;
=end EXPORTS

=DESCRIPTION

=head2 enum Net::Pcap::Linktype
=begin pod
Enumerator for libpcaps link-layer type.
=end pod

unit module Net::Pcap::Linktype;

enum Net::Pcap::Linktype (
    Null => 0,
    Ethernet => 1,
);

my constant Linktype is export(:short) ::= Net::Pcap::Linktype;

