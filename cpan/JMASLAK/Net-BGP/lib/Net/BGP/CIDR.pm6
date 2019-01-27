use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use StrictClass;
unit class Net::BGP::CIDR:ver<0.0.8>:auth<cpan:JMASLAK> does StrictClass;

use Net::BGP::IP;

# Public Attributes
has UInt:D $.prefix-int    is required;
has UInt:D $.prefix-length is required where ^129;

our subset IP-Version where * == 4|6;
has IP-Version $.ip-version = 2;

# Private
has Str $!cached-str;

method from-int(
    UInt() $ip,
    UInt() $len where ^129,
    IP-Version:D $ip-ver? = 4
) {
    if $ip-ver == 4 and $len > 32 { die("Prefix too long for IPv4 CIDR") }
    return self.bless(
        :prefix-int($ip),
        :prefix-length($len),
        :ip-version($ip-ver),
    );
}

method from-str(Str:D $ip) {
    my @parts = $ip.split('/');
    if @parts.elems ≠ 2 { die("Invalid CIDR"); }

    if $ip.contains(':') {
        # IPv6
        return self.from-int(ipv6-to-int(@parts[0]), @parts[1].Int, 6);
    } else {
        # IPv4
        return self.from-int(ipv4-to-int(@parts[0]), @parts[1].Int, 4);
    }
}

method packed-to-array(
    buf8:D $buf,
    IP-Version:D $ip-ver? = 4
    -->Array[Net::BGP::CIDR:D]
) {
    if $ip-ver == 4 {
        return self.ipv4-packed-to-array($buf);
    } else {
        return self.ipv6-packed-to-array($buf);
    }
}

method ipv4-packed-to-array(buf8:D $buf -->Array[Net::BGP::CIDR:D]) {
     my Net::BGP::CIDR:D @nlri = gather {
        while $buf.bytes {
            my $len = $buf[0];
            if $len > 32 { die("Pack length too long"); }

            my $bytes = (($len+7) / 8).truncate;
            if $buf.bytes < (1 + $bytes) { die("Pack payload too short") }

            my uint32 $ip = 0;
            if $bytes > 0 { $ip += $buf[1] +< 24; }
            if $bytes > 1 { $ip += $buf[2] +< 16; }
            if $bytes > 2 { $ip += $buf[3] +< 8; }
            if $bytes > 3 { $ip += $buf[4]; }

            $ip = $ip +> (32 - $len) +< (32 - $len);  # Zero any trailing bits
            take self.from-int($ip, $len, 4);

            $buf.splice: 0, $bytes+1, ();
        }
    }

    return @nlri;
}

method ipv6-packed-to-array(buf8:D $buf -->Array[Net::BGP::CIDR:D]) {
     my Net::BGP::CIDR:D @nlri = gather {
        while $buf.bytes {
            my $len = $buf[0];
            if $len > 128 { die("Pack length too long"); }

            my $bytes = (($len+7) / 8).truncate;
            if $buf.bytes < (1 + $bytes) { die("Pack payload too short") }

            my UInt $ip = 0;
            if $bytes >  0 { $ip += $buf[ 1] +< 120; }
            if $bytes >  1 { $ip += $buf[ 2] +< 112; }
            if $bytes >  2 { $ip += $buf[ 3] +< 104; }
            if $bytes >  3 { $ip += $buf[ 4] +<  96; }
            if $bytes >  4 { $ip += $buf[ 5] +<  88; }
            if $bytes >  5 { $ip += $buf[ 6] +<  80; }
            if $bytes >  6 { $ip += $buf[ 7] +<  72; }
            if $bytes >  7 { $ip += $buf[ 8] +<  64; }
            if $bytes >  8 { $ip += $buf[ 9] +<  56; }
            if $bytes >  9 { $ip += $buf[10] +<  48; }
            if $bytes > 10 { $ip += $buf[11] +<  40; }
            if $bytes > 11 { $ip += $buf[12] +<  32; }
            if $bytes > 12 { $ip += $buf[13] +<  24; }
            if $bytes > 13 { $ip += $buf[14] +<  16; }
            if $bytes > 14 { $ip += $buf[15] +<   8; }
            if $bytes > 15 { $ip += $buf[16]; }

            $ip = $ip +> (128 - $len) +< (128 - $len);  # Zero any trailing bits
            take self.from-int($ip, $len, 6);

            $buf.splice: 0, $bytes+1, ();
        }
    }

    return @nlri;
}

method to-packed(-->buf8:D) {
    if self.ip-version == 4 {
        return self.ipv4-to-packed;
    } else {
        return self.ipv6-to-packed;
    }
}

method ipv4-to-packed(-->buf8:D) {
    my int32 $ip = $!prefix-int +> (32 - $!prefix-length);
    $ip = $ip +< (32 - $!prefix-length);

    my $buf = buf8.new;

    $buf.append: $!prefix-length;
    $buf.append(  $ip +> 24        ) if $!prefix-length >  0;
    $buf.append( ($ip +> 16) % 256 ) if $!prefix-length >  8;
    $buf.append( ($ip +>  8) % 256 ) if $!prefix-length > 16;
    $buf.append(  $ip        % 256 ) if $!prefix-length > 24;

    return $buf;
}

method ipv6-to-packed(-->buf8:D) {
    my UInt $ip = $!prefix-int +> (128 - $!prefix-length);
    $ip = $ip +< (128 - $!prefix-length);

    my $buf = buf8.new;

    $buf.append: $!prefix-length;
    $buf.append(  $ip +> 120        ) if $!prefix-length >   0;
    $buf.append( ($ip +> 112) % 256 ) if $!prefix-length >   8;
    $buf.append( ($ip +> 104) % 256 ) if $!prefix-length >  16;
    $buf.append( ($ip +>  96) % 256 ) if $!prefix-length >  24;
    $buf.append( ($ip +>  88) % 256 ) if $!prefix-length >  32;
    $buf.append( ($ip +>  80) % 256 ) if $!prefix-length >  40;
    $buf.append( ($ip +>  72) % 256 ) if $!prefix-length >  48;
    $buf.append( ($ip +>  64) % 256 ) if $!prefix-length >  56;
    $buf.append( ($ip +>  56) % 256 ) if $!prefix-length >  64;
    $buf.append( ($ip +>  48) % 256 ) if $!prefix-length >  72;
    $buf.append( ($ip +>  40) % 256 ) if $!prefix-length >  80;
    $buf.append( ($ip +>  32) % 256 ) if $!prefix-length >  88;
    $buf.append( ($ip +>  24) % 256 ) if $!prefix-length >  96;
    $buf.append( ($ip +>  16) % 256 ) if $!prefix-length > 104;
    $buf.append( ($ip +>   8) % 256 ) if $!prefix-length > 112;
    $buf.append(  $ip         % 256 ) if $!prefix-length > 120;

    return $buf;
}

method str-to-packed(Str:D $ip -->buf8:D) { return self.from-str($ip).to-packed }

multi method contains(Net::BGP::CIDR:D $cidr -->Bool:D) {
    if self.prefix-length > $cidr.prefix-length { return False }
    if self.ip-version    ≠ $cidr.ip-version    { return False }

    if self.ip-version == 4 {
        my uint32 $mask = 2³² - 2**(32 - self.prefix-length);
        if (self.prefix-int +& $mask) == ($cidr.prefix-int +& $mask) { return True; }
        return False;
    } else {
        my UInt $mask = 2¹²⁸ - 2**(128 - self.prefix-length);
        if (self.prefix-int +& $mask) == ($cidr.prefix-int +& $mask) { return True; }
        return False;
    }
}

method Str(-->Str:D) {
    if ! self.defined { return "Net::BGP::CIDR" }
    return $!cached-str if $!cached-str.defined;

    if self.ip-version == 4 {
        $!cached-str = int-to-ipv4($!prefix-int) ~ "/$!prefix-length"
    } else {
        $!cached-str = int-to-ipv6($!prefix-int) ~ "/$!prefix-length"
    }

    return $!cached-str;
}

=begin pod

=head1 NAME

Net::BGP::CIDR - IPv4/IPv6 CIDR Handling Functionality

=head1 SYNOPSIS

  use Net::BGP::CIDR;

  my $ip1 = IP::BGP::CIDR->from-str('192.0.2.0/24');
  my $ip2 = IP::BGP::CIDR->from-int(0, 0);
  my $ip3 = IP::BGP::CIDR->from-str('2001:db8:3333:1::/48');
  my $ip4 = IP::BGP::CIDR->from-int(0, 0, ipv6);
  
  say $ip1;

=head1 ATTRIBUTES

=head2 prefix-int

The integer value of the prefix address.

=head2 prefix-length

The integer value of the prefix length.

method packed-to-array

Takes a "packed" buffer of length + prefix and converts it into an array of
C<Net::BGP::CIDR> objects.  These "packed" buffers are common in BGP structures.

=method to-packed

Takes a C<Net::BGP::CIDR> object and produces a packed representation.

=head1 METHODS

=head2 from-int

Converts an integer prefix and integer length into a CIDR object.  This will
take an optional third parameter, either C<ipv4> or C<ipv6>.  This parameter
defaults to C<ipv4>.

=head2 from-str

Converts a CIDR in format C<0.1.2.3/4> into a CIDR object.

=head2 contains

Returns true if this CIDR object contains another CIDR (passed as the first
argument).

=head2 Str

Returns a string representation of a CIDR object.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artisitc License 2.0.

=end pod

