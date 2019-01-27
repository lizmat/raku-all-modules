use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

unit module Net::BGP::SAFI:ver<0.0.8>:auth<cpan:JMASLAK>;
my %safi-names := Hash[Int:D,Str:D].new;

my %safi-codes := {
        1 => 'unicast',
        2 => 'multicast',
        4 => 'MPLS',
        5 => 'MCAST-VPN',
        6 => 'Multi-Segment-Pseudowires',
        7 => 'Encapsulation',
        8 => 'MCAST-VPLS',
       64 => 'Tunnel',
       65 => 'VPLS',
       66 => 'MDT',
       67 => '4over6',
       68 => '6over4',
       69 => 'Layer-1-VPN-Auto-Discovery',
       70 => 'EVPN',
       71 => 'LS',
       72 => 'LS-VPN',
       73 => 'SR-TE-Policy',
       74 => 'SD-WAN-Capabilities',
      128 => 'MPLS-labeled-VPN',
      129 => 'Multicast-MPLS-VPN',
      132 => 'Route-Target-Constraints',
      133 => 'IPv4-Flow-Spec',
      134 => 'IPv6-Flow-Spec',
      140 => 'VPN-Auto_Discovery',
};

for %safi-codes -> $pair {
    %safi-names{ $pair.value } = $pair.key.Int;
}

sub safi-name(Int:D $safi -->Str:D) is export(:ALL, :safi-code) {
    return %safi-codes{$safi}:exists ?? %safi-codes{$safi} !! "$safi";
}

sub safi-code(Str:D $name -->Int:D) is export(:ALL, :safi-code) {
    if %safi-names{$name}:exists {
        return %safi-names{$name};
    }
    if $name ~~ /^ <[ 0..9 ]>+ $/ {
        return +$name;
    }
    die("Invalid SAFI name");
}

=begin pod

=head1 NAME

Net::BGP::Message::SAFI - BGP SAFIs

=head1 SYNOPSIS

  use Net::BGP::SAFI;

  my $name = Net::BGP::SAFI::safi-name(1);         # unicast
  my $code = Net::BGP::SAFI::safi-code("unicast"); # 2

=head1 DESCRIPTION

BGP Subsequent Address Family Indicators

=head1 Subroutines

=head2 safi-name(Int:D $safi -->Str:D)

Returns the name corresponding to an integer SAFI code.

=head2 safi-code(Str:D $name -->Int:D)

Returns the integer represeinting the SAFI from the string name.  Throws an
exception upon unrecognized SAFIs.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
