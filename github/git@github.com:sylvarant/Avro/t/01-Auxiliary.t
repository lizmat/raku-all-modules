use v6;
use Test;
use lib 'lib';
use Avro; 
use Avro::Auxiliary;

plan 24;

#======================================
# Test ZigZag
#======================================

is to_zigzag(1),2,"To zigzag 1 works";
is to_zigzag(-2),3,"To zigzag -2 works";
is from_zigzag(4294967294),2147483647,"From zigzag large number works";
is from_zigzag(4294967295),-2147483648,"From zigzag small number works";


#======================================
# Variable int
#======================================

my %hash =  128 => [128,1], 130 => [130,1], 16383 => [0xff,127];

for %hash.keys -> $num {
  is-deeply to_varint(+$num),%hash{$num},"To variable int works for $num";
  is-deeply from_varint(%hash{$num}),+$num,"From variable int works for $num";
}


#======================================
# Floating point stuff
#======================================

is-deeply frexp(8.0), (4,0.5), "frexp works for 8.0";
is-deeply from_floatbits(0x41c80000),25.0,"Reading bytes to float works for 25.0";
is-deeply from_floatbits(0xc0000000),-2.0,"Reading bytes to float works for -2.0";

is-deeply to_floatbits(25.0),0x41c80000,"Encoded 25 to float correctly";
is-deeply to_floatbits(-2.0),0xc0000000,"Encoded -2.0 to float correctly";
is-deeply from_floatbits(to_floatbits(12.375)),12.375,"Reversed 12.375 correctly";
is-deeply from_floatbits(to_floatbits(2.5)),2.5,"Reversed 2.5 Correctly";

#say to_floatbits(0.02);
#say from_floatbits(to_floatbits(0.02));

#is-deeply from_floatbits(to_floatbits(2.02)),2.02;
is-deeply from_floatbits(to_floatbits(0.5)),0.5, "Reversed 0.5 correctly";
is-deeply from_floatbits(to_floatbits(1.0)),1.0, "Reversed 1 correctly";

is-deeply from_floatbits(int_from_bytes(int_to_bytes(to_floatbits(25.0),4))),25.0,"converted to byte arrays correctly";

is-deeply from_doublebits(0x3ff0000000000000),1.0,"Reading bytes to double works for 1";
is-deeply from_doublebits(0x3ff0000000000002).round(0.00000000000000001),1.00000000000000044,"Reading bytes for small number works";
is-deeply from_doublebits(to_doublebits(0.5)),0.5, "Reversed 0.5 correctly";
is-deeply from_doublebits(to_doublebits(2.5)),2.5,"Reversed 2.5 Correctly";

