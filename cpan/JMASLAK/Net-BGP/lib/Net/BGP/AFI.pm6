use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

unit module Net::BGP::AFI:ver<0.0.9>:auth<cpan:JMASLAK>;

my %afi-names := Hash[Int:D,Str:D].new;

my %afi-codes := {
        1 => 'IP',
        2 => 'IPv6',
        3 => 'NSAP',
        4 => 'HDLC',
        5 => 'BBN 1882',
        6 => '802',
        7 => 'E.163',
        8 => 'E.164',
        9 => 'F.69',
       10 => 'X.121',
       11 => 'IPX',
       12 => 'Appletalk',
       13 => 'Decnet IV',
       14 => 'Banyan Vines',
       15 => 'E.164 with NSAP',
       16 => 'DNS',
       17 => 'Distinguished Name',
       18 => 'AS Number',
       19 => 'XTPoIPv4',
       20 => 'XTPoIPv6',
       21 => 'XTP',
       22 => 'FC WWPN',
       23 => 'FC WWNN',
       24 => 'GWID',
       25 => 'L2VPN',
       26 => 'MPLS-TP Section',
       27 => 'MPLS-TP LSP',
       28 => 'MPLS-TP Psuedowire',
       29 => 'MT IP',
       30 => 'MT IPv6',
    16384 => 'EIGRP Common',
    16385 => 'EIGRP IPv4',
    16386 => 'EIGRP IPv6',
    16387 => 'LISP',
    16388 => 'BGP-LS',
    16389 => 'MAC48',
    16390 => 'MAC64',
    16391 => 'OUI',
    16392 => 'MAC24',
    16393 => 'MAC40',
    16394 => 'IPv6-64',
    16395 => 'RBridge Port',
    16396 => 'TRILL'
};

for %afi-codes -> $pair {
    %afi-names{ $pair.value } = $pair.key.Int;
}

sub afi-name(Int:D $afi -->Str:D) is export(:ALL, :afi-code) {
    return %afi-codes{$afi}:exists ?? %afi-codes{$afi} !! "$afi";
}

sub afi-code(Str:D $name -->Int:D) is export(:ALL, :afi-code) {
    if %afi-names{$name}:exists {
        return %afi-names{$name};
    }
    if $name ~~ /^ <[ 0..9 ]>+ $/ {
        return +$name;
    }
    die("Invalid AFI name");
}

=begin pod

=head1 NAME

Net::BGP::Message::AFI - BGP AFIs

=head1 SYNOPSIS

  use Net::BGP::AFI :ALL;

  my $name = afi-name(2);    # IP
  my $code = afi-code("IP"); # 2

=head1 DESCRIPTION

BGP Address Family Indicators

=head1 Subroutines

=head2 afi-name(Int:D $afi -->Str:D)

Returns the name corresponding to an integer AFI code.

=head2 afi-code(Str:D $name -->Int:D)

Returns the integer represeinting the AFI from the string name.  Throws an
exception upon unrecognized AFIs.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
