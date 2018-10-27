=NAME
Net::Packet::EtherType - Enumerator to describe EtherType.

=begin SYNOPSIS
    use Net::Packet::EtherType :short;

    my $etype_Int = 0x0800; # EtherType value of IPv4
    my $etype = EtherType($etype_Int);
    say $etype; # 'IPv4'

    $etype = EtherType::IPv4;
    say $etype.value.base(16); # '800'

    say EtherType.enums; # Prints all implemented values.
=end SYNOPSIS

=DESCRIPTION

=head2 enum Net::Packet::EtherType

unit module Net::Packet::EtherType;

enum Net::Packet::EtherType (
    IPv4             => 0x0800,
    ARP              => 0x0806,
    IEEE802_1Q       => 0x8100,	    
    IEEE802_1ad      => 0x88A8,
);

my constant EtherType is export(:short) ::= Net::Packet::EtherType;

