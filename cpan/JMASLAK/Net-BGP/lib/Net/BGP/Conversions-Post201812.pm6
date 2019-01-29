use v6.d;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

#
# Helper subs for Rakudo 2018.12+
#

unit module Net::BGP::Conversions-Post201812:ver<0.1.0>:auth<cpan:JMASLAK>;

sub _nuint16(buf8 $b where $b.bytes == 2 --> Int) is export {
    return $b.read-uint16(0, BigEndian);
}

sub _nuint32(buf8 $b, Int:D $pos? = 0 --> Int) is export {
    return $b.read-uint32($pos, BigEndian);
}

sub _nuint128(buf8 $b where $b.bytes == 16 --> Int) is export {
    return $b.read-uint128(0, BigEndian);
}

