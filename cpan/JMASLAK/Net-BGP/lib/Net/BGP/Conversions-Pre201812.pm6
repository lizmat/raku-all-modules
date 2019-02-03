use v6.d;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

#
# Helper subs for Rakudo ≤ 2018.11
#

unit module Net::BGP::Conversions-Pre201812:ver<0.1.1>:auth<cpan:JMASLAK>;

sub _nuint16(buf8 $b where $b.bytes == 2 --> Int) is export {
    return $b[0] × 2⁸ + $b[1];
}

sub _nuint32(buf8 $b, Int:D $pos? = 0 --> Int) is export {
    return $b[0+$pos] * 2²⁴ + $b[1+$pos] * 2¹⁶ + $b[2+$pos] * 2⁸ + $b[3+$pos];
}

sub _nuint128(buf8 $b where $b.bytes == 16 --> Int) is export {
    return (_nuint32($b.subbuf( 0,4)) +< 96)
         + (_nuint32($b.subbuf( 4,4)) +< 64)
         + (_nuint32($b.subbuf( 8,4)) +< 32)
         +  _nuint32($b.subbuf(12,4));
}

