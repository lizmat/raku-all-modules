=NAME
Net::Packet::IP_proto

=begin SYNOPSIS
    use Net::Packet::IP_proto :short;

    my $ipproto_Int = 0x06;
    my $ipproto = IP_proto($ipproto_Int);
    say $ipproto; # 'TCP'

    $ipproto = IP_proto::UDP;
    say $ipproto.value.base(16); # '11'

    say IP_proto.enums; # Lists all implemented values.
=end SYNOPSIS

=begin EXPORTS
    Net::Packet::IP_proto

:short trait adds export:

    constant IP_proto ::= Net::Packet::IP_proto;
=end EXPORTS

=DESCRIPTION

=head2 enum Net::Packet::IP_proto

unit module Net::Packet::IP_proto;

enum Net::Packet::IP_proto (
    ICMP => 0x01,
    TCP => 0x06,
    UDP => 0x11,
);

my constant IP_proto is export(:short) ::= Net::Packet::IP_proto;

