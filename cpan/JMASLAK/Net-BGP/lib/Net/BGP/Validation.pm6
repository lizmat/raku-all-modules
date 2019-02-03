use v6.d;

#
# Copyright © 2019 Joelle Maslak
# All Rights Reserved - See License
#

unit module Net::BGP::Validation:ver<0.1.1>:auth<cpan:JMASLAK>;

use Net::BGP::CIDR;
use Net::BGP::Message;
use Net::BGP::Message::Update;

my %ERRORS;
%ERRORS<AFMIX>                  = "Multiple Address Families in a single BGP Update";
%ERRORS<AGGR_ASN_DOC>           = "Aggregator ASN is a documentation ASN";
%ERRORS<AGGR_ASN_PRIVATE>       = "Aggregator ASN is a private ASN";
%ERRORS<AGGR_ASN_RESERVED>      = "Aggregator ASN is a reserved ASN";
%ERRORS<AGGR_ASN_TRANS>         = "Aggregator ASN is the AS_TRANS ASN";
%ERRORS<AGGR_ID_BOGON>          = "Aggregator ID is a bogon";
%ERRORS<AS_PATH_DOC>            = "ASN Path contains a documentation ASN";
%ERRORS<AS_PATH_PRIVATE>        = "ASN Path contains a private ASN";
%ERRORS<AS_PATH_RESERVED>       = "ASN Path contains a reserved ASN";
%ERRORS<AS_PATH_TRANS>          = "ASN Path contains the AS_TRANS ASN";
%ERRORS<AS4_PEER_SENT_AS4_PATH> = "AS4-capable peer sent an AS4-Path attribute";

my Net::BGP::CIDR:D @BOGONS =
    Net::BGP::CIDR.from-str('0.0.0.0/8'),
    Net::BGP::CIDR.from-str('10.0.0.0/8'),
    Net::BGP::CIDR.from-str('100.64.0.0/10'),
    Net::BGP::CIDR.from-str('127.0.0.0/8'),
    Net::BGP::CIDR.from-str('172.16.0.0/12'),
    Net::BGP::CIDR.from-str('192.0.0.0/24'),
    Net::BGP::CIDR.from-str('192.0.2.0/24'),
    Net::BGP::CIDR.from-str('192.168.0.0/16'),
    Net::BGP::CIDR.from-str('198.18.0.0/15'),
    Net::BGP::CIDR.from-str('198.51.100.0/24'),
    Net::BGP::CIDR.from-str('203.0.113.0/24'),
    Net::BGP::CIDR.from-str('224.0.0.0/3'),
;
my Net::BGP::CIDR:D $ZERO = Net::BGP::CIDR.from-str('0.0.0.0/32');

our sub errors(
    Net::BGP::Message:D :$message,
    UInt:D :$my-asn,
    UInt:D :$peer-asn,
    -->Array[Pair:D]
) {
    return error_dispatch(:$message, :$my-asn, :$peer-asn);
}

multi sub error_dispatch(
    Net::BGP::Message::Update:D :$message,
    UInt:D :$my-asn,
    UInt:D :$peer-asn,
    -->Array[Pair:D]
) {
    my Pair:D @errors;

    # Check address families
    if ($message.nlri.elems or $message.withdrawn.elems)
        && ($message.nlri6.elems or $message.withdrawn6.elems)
    {
        @errors.push: error('AFMIX');
    }

    # Check aggregator
    my $agg = update-check-aggregator(:$message, :$my-asn, :$peer-asn);
    if $agg.elems { @errors.append: @$agg }

    # check path
    my $pth = update-check-aspath(:$message, :$my-asn, :$peer-asn);
    if $pth.elems { @errors.append: @$pth }

    return @errors;
}

sub check-asn(
    UInt:D $asn,
    UInt:D $my-asn,
    UInt:D $peer-asn,
    -->Str
) {
    if $asn == $my-asn                      { return Str; }
    if $asn == $peer-asn                    { return Str; }
    if $asn == 0                            { return 'RESERVED'; }
    if $asn == 23456                        { return 'TRANS'; }
    if 64496 ≤ $asn ≤ 64511                 { return 'DOC'; }
    if 64512 ≤ $asn ≤ 65534                 { return 'PRIVATE'; }
    if $asn == 65535                        { return 'RESERVED'; }
    if 65536 ≤ $asn ≤ 65551                 { return 'DOC'; }
    if 65552 ≤ $asn ≤ 131071                { return 'RESERVED'; }
    if 4_200_000_000 ≤ $asn ≤ 4_294_967_294 { return 'PRIVATE'; }
    if $asn == 4_294_967_295                { return 'RESERVED'; }

    return Str;
}

sub update-check-aggregator(
    Net::BGP::Message::Update:D :$message,
    UInt:D :$my-asn,
    UInt:D :$peer-asn,
    -->Array[Pair:D]
) {
    my Pair:D @errors;

    if $message.aggregator-asn.defined {
        given check-asn($message.aggregator-asn, $my-asn, $peer-asn) {
            when "RESERVED" { @errors.push(error('AGGR_ASN_RESERVED')) }
            when "TRANS"    { @errors.push(error('AGGR_ASN_TRANS')) }
            when "DOC"      { @errors.push(error('AGGR_ASN_DOC')) }
            when "PRIVATE"  { @errors.push(error('AGGR_ASN_PRIVATE')) }
        }

        my $id-cidr = Net::BGP::CIDR.from-str($message.aggregator-ip ~ '/32');
        if $id-cidr.contains($ZERO) {
            # Not an issue, this is legitimate.
        } elsif @BOGONS.first({ $^a.contains($id-cidr) }).defined {
            @errors.push: error('AGGR_ID_BOGON');
        }
    }

    return @errors;
}

sub update-check-aspath(
    Net::BGP::Message::Update:D :$message,
    UInt:D :$my-asn,
    UInt:D :$peer-asn,
    -->Array[Pair:D]
) {
    my Pair:D @errors;

    my $as4 = $message.path-attributes.first( * ~~ Net::BGP::Path-Attribute::AS4-Path );
    my $as  = $message.path-attributes.first( * ~~ Net::BGP::Path-Attribute::AS-Path );

    if ($message.nlri.elems + $message.nlri6.elems) == 0 {
        # XXX we shouldn't have these path attributes
        return @errors;
    }

    # XXX We should validate we don't see more than one of these.

    if $as4.defined and $message.asn32 {
        @errors.push: error('AS4_PEER_SENT_AS4_PATH');
    }

    my $reserved = 0;
    my $trans    = 0;
    my $doc      = 0;
    my $private  = 0;

    my @asns = $message.as-array;
    for @asns.unique -> $asn {
        given check-asn($asn, $my-asn, $peer-asn) {
            when "RESERVED" { @errors.push(error('AS_PATH_RESERVED')) if ! $reserved++ }
            when "TRANS"    { @errors.push(error('AS_PATH_TRANS'))    if ! $trans++    }
            when "DOC"      { @errors.push(error('AS_PATH_DOC'))      if ! $doc++      }
            when "PRIVATE"  { @errors.push(error('AS_PATH_PRIVATE'))  if ! $private++  }
        }
    }

    return @errors;
}

multi sub error_dispatch(
    Net::BGP::Message:D :$message,
    UInt:D :$my-asn,
    UInt:D :$peer-asn,
    -->Array[Pair:D]
) {
    my Pair:D @errors;
    # Currently we don't do any checking.
    return @errors;
}

sub error(Str:D $short --> Pair:D) {
    if %ERRORS{$short}:!exists { die("Error type $short does not exist") }
    return $short => %ERRORS{$short};
}

=begin pod

=head1 NAME

Net::BGP::Validation - Validate BGP Messages (Lint Mode)

=head1 SYNOPSIS

  ues Net::BGP::Validation;

  my @errors = Net::BGP::Validation::errors($msg);

=head1 ROUTINES

=head2 errors

Takes a BGP message, returns an array of pairs representing the warnings/errors
found in the message.  The key of the pair is the short code, the value is
a long description.

=head3 AFMIX

  Multiple Address Families in a single BGP Update

This BGP update contains both IPv4 and IPv6 NLRIs and/or withdrawn prefixes.

=head3 AGGR_ASN_DOC

  Aggregator ASN is a documentation ASN

This message has an Aggregator path-attribute with an ASN using a range of
ASNs reserved for use in documentation.

=head3 AGGR_ASN_PRIVATE

  Aggregator ASN is a private ASN

This message has an Aggregator path-attribute with an ASN using a range of
ASNs reserved for private use.

=head3 AGGR_ASN_RESERVED

  Aggregator ASN is a reserved ASN

This message has an Aggregator path-attribute with an ASN using a range of
ASNs that IANA indicates is "reserved".

=head3 AGGR_ASN_TRANS

  Aggregator ASN is the AS_TRANS ASN

This message has an Aggregator path-attribute with an ASN of 23456, which is
the BGP4 transitional ASN (and should not be seen on the internet after
processing an UPDATE message looking for an AS4_Aggregator path-attribute).

=head3 AGGR_ID_BOGON

  Aggregator ID is a bogon

This message has an Aggregator path-attribute with an IP in the bogon range
(except 0.0.0.0, which is valid).

=head3 AS_PATH_DOC

  ASN Path contains a documentation ASN

This UPDATE message has an AS path with an ASN in the doucmentation range.

=head3 AS_PATH_PRIVATE

  ASN Path contains a private ASN

This UPDATE message has an AS path with an ASN in the private range.

=head3 AS_PATH_RESERVED

  ASN Path contains a reserved ASN

This UPDATE message has an AS path with an ASN in the reserved range.

=head3 AS_PATH_TRANS

  ASN Path contains a contains the AS_TRANS ASN

This UPDATE message has an AS path that contains 23456 (AS_TRANS).

=head3 AS4_PEER_SENT_AS4_PATH

  AS4-capable peer sent an AS4-Path attribute

An update message sent from an AS4-capable peer contains an AS4-Path attribute.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artisitc License 2.0.

=end pod

