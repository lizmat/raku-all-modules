use v6.d;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

unit module Net::BGP::Conversions:ver<0.1.0>:auth<cpan:JMASLAK>;

use if;

# Select right helper library based on compiler version
use Net::BGP::Conversions-Pre201812:if( $*PERL.compiler.version ≤ v2018.11);
use Net::BGP::Conversions-Post201812:if($*PERL.compiler.version > v2018.11);

use Net::BGP::IP;

multi sub nuint16(@a where @a.elems == 2 --> Int) is export {
    return nuint16(@a[0], @a[1]);
}
multi sub nuint16(buf8 $b where $b.bytes == 2 --> Int) is export { _nuint16($b) }
multi sub nuint16(byte $a, byte $b --> Int) is export {
    return $a × 2⁸ + $b;
}


multi sub nuint32(@a where @a.elems == 4 --> Int) is export {
    return nuint32(@a[0], @a[1], @a[2], @a[3]);
}
multi sub nuint32(buf8 $b, Int $pos? = 0 --> Int) is export { _nuint32($b, $pos) }
multi sub nuint32(byte $a, byte $b, byte $c, byte $d --> Int) is export {
    return $a × 2²⁴ + $b × 2¹⁶ + $c × 2⁸ + $d;
}


multi sub nuint128(@b where @b.elems == 16 --> Int) is export {
    my Int $i = 0;
    for @b -> $b { $i = ( $i +< 8 ) + $b }
    return $i;
}
multi sub nuint128(buf8 $b where $b.bytes == 16 --> Int) is export { _nuint128($b) }
multi sub nuint128(*@b where @b.elems == 16 --> Int) is export {
    return nuint128(@b);
}


sub nuint16-buf8(Int $n where * < 2¹⁶ --> buf8) is export {
    return buf8.new($n +> 8, $n +& 255);
}


multi sub nuint32-buf8(Int $n where * < 2³² --> buf8) is export {
    return buf8.new($n +> 24 +& 255, $n +> 16 +& 255, $n +> 8 +& 255, $n +& 255);
}
multi sub nuint32-buf8(Int $n --> buf8) is export {
    return buf8.new($n +> 24 +& 255, $n +> 16 +& 255, $n +> 8 +& 255, $n +& 255);
}
# XXX Regexes are slow.
#multi sub nuint32-buf8(Net::BGP::IP::ipv4 $ip --> buf8) is export {
multi sub nuint32-buf8(Str:D $ip --> buf8) is export {
    return nuint32-buf8(ipv4-to-int($ip));
}
sub nuint128-buf8(Int $n where * < 2¹²⁸ --> buf8) is export {
    my $d = nuint32-buf8( ($n +> 96) +& ((2³²)-1) );
    my $c = nuint32-buf8( ($n +> 64) +& ((2³²)-1) );
    my $b = nuint32-buf8( ($n +> 32) +& ((2³²)-1) );
    my $a = nuint32-buf8(  $n        +& ((2³²)-1) );

    return buf8.new($d.list, $c.list, $b.list, $a.list);
}

=begin pod

=head1 NAME

Net::BGP::Conversions - Convert between bytes and integer formats

=head1 SYNOPSIS

  ues Net::BGP::Conversions;

  my $val1 = nuint16(10, 20);
  my $val2 = nuint32(10, 20, 30, 40);

  my $buf1 = nuint16-buf8(1000);
  my $buf2 = nuint32-buf8(1_000_000);

=head1 ROUTINES

=head2 nuint16

  my $val1 = nuint16(10, 20);
  my $val2 = nuint16(@array); # Must be a 2 element array
  my $val2 = nuint16($buf);   # Must be a buf8 that is 2 bytes long

Converts the byte values in the parameter to a 16 bit UInt, assuming network
ordering (first byte is MSB).

=head2 nuint32

  my $val1 = nuint32(10, 20, 30, 40);
  my $val2 = nuint32(@array); # Must be a 4 element array
  my $val2 = nuint32($buf);   # Must be a buf8 that is 4 bytes long

Converts the byte values in the parameter to a 32 bit UInt, assuming network
ordering (first byte is MSB).

=head2 nuint16-buf8

  my $buf1 = nuint16-buf8(1000);

Returns a C<buf8> object containing two bytes representing the network byte
order value of the integer parameter.

=head2 nuint32-buf8

  my $buf2 = nuint32-buf8(1_000_000);

Returns a C<buf8> object containing four bytes representing the network byte
order value of the integer parameter.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artisitc License 2.0.

=end pod

