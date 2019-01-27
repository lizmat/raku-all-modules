use v6;

#
# Copyright © 2019 Joelle Maslak
# All Rights Reserved - See License
#

use StrictClass;
unit class Net::BGP::AFI-SAFI:ver<0.0.8>:auth<cpan:JMASLAK> does StrictClass;

use Net::BGP::AFI  :ALL;
use Net::BGP::SAFI :ALL;

has Int:D $.afi-code  is required;
has Int:D $.safi-code is required;

method afi-name( -->Str:D) { return  afi-name( $!afi-code) }
method safi-name(-->Str:D) { return safi-name($!safi-code) }

submethod from-str($afi, $safi -->Net::BGP::AFI-SAFI:D) {
    my $acode =  afi-code($afi);
    my $scode = safi-code($safi);

    return Net::BGP::AFI-SAFI.new(:afi-code($acode), :safi-code($scode));
}

multi sub infix:<==>(Net::BGP::AFI-SAFI $a, Net::BGP::AFI-SAFI $b -->Bool:D) {
    return False if $a.afi-code ≠ $b.afi-code;
    return $a.safi-code == $b.safi-code;
}

=begin pod

=head1 NAME

Net::BGP::Message::AFI-SAFI - BGP AFI + SAFIs

=head1 SYNOPSIS

  use Net::BGP::AFI-SAFI;

  my $family = Net::BGP::AFI-SAFI.from-str('IPv6', 'unicast');

=head1 DESCRIPTION

BGP Address Family Indicators

=head1 Attributes

=head2 afi-code

The integer AFI code represented in this object.

=head2 safi-code

The integer SAFI code represented in this object.

=head1 Subroutines

=head2 afi-name(-->Str:D)

Returns the name corresponding to this object's AFI code.

=head2 safi-name(-->Str:D)

Returns the name corresponding to this object's SAFI code.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
