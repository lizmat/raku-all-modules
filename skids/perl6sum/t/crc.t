use v6;
use lib	'./lib';

use Test;

plan 133;

use Sum::CRC;
ok(1,'We use Sum::CRC and we are still alive');

my ($i, $s);

class ROHC does Sum::CRC_3_ROHC does Sum::Marshal::Bits[:reflect] { }
my ROHC $rohc .= new();
is ROHC.size, 3, "CRC .size method works.  And is a class method";
is +$rohc.finalize(0x31..0x39), 0x6, "CRC_3_ROHC gives expected results";
ok $rohc.check(False,True,True), "CRC_3_ROHC self-verifies (0)";
is +ROHC.new.finalize(3,1,4,1,5,9,2,6,4), 7, "CRC_3_ROHC additional vector 1";
is +ROHC.new.finalize(1,6,1,8,0,3,3,9,8,8), 2, "CRC_3_ROHC additional vector 2";
is ROHC.new.finalize(3,1,4,1,5,9,2,6,4).base(16), "7", ".base(16) on a 3-bit result";
is ROHC.new.finalize(3,1,4,1,5,9,2,6,4).fmt, "07", ".fmt on a 3-bit result";
is ROHC.new.finalize(1,6,1,8,0,3,3,9,8,8).base(2), "010", ".base(2) on a 3-bit result";

class CRC4ITU does Sum::CRC_4_ITU does Sum::Marshal::Bits { :reflect }
my CRC4ITU $itu4 .= new();
is +$itu4.finalize(0x31..0x39), 0x7, "CRC_4_ITU gives expected results";
ok $itu4.check(True,True,True,False,False), "CRC_4_ITU self-verifies (0)";

# "Specification for RFID Air Interface" Version 1.2.0 EPCGlobal
class CRC5EPC does Sum::CRC_5_EPC does Sum::Marshal::Raw { }
my CRC5EPC $s5e .= new();
is +$s5e.finalize(?<<(1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0)), 0x13, "CRC_5_EPC gives expected results";
is +$s5e.finalize(?<<(1,0,0,1,1)), 0, "CRC_5_EPC self-verifies (0)";

class CRC5ITU does Sum::CRC_5_ITU does Sum::Marshal::Bits { :reflect }
my CRC5ITU $itu5 .= new();
is +$itu5.finalize(0x31..0x39), 0x7, "CRC_5_ITU gives expected results";
ok $itu5.check(True,True,True,False,False), "CRC_5_ITU self-verifies (0)";

# Test sum and value from "CYCLIC REDUNDANCY CHECKS IN USB" crcdes.pdf usb.org
class USBToken does Sum::CRC_5_USB does Sum::Marshal::Bits[ :bits(5) ] { }
$s = USBToken.new();
$i = $s.finalize(?<<(1,0,1,0,1,0,0,0,1,1,1));
is +$i, 0x17, "CRC_5_USB gives expected results";
ok $s.check(+$i), "CRC_5_USB self-verifies (residual) ";

class CRC6DARC does Sum::CRC_6_DARC does Sum::Marshal::Bits[ :reflect ] { }
my CRC6DARC $d6 .= new();
is +$d6.finalize(0x31..0x39), 0x26, "CRC_6_DARC gives expected results";
ok $d6.check(False,True,True,False,False,True), "CRC_6_DARC self-verifies (0)";

class CRC6ITU does Sum::CRC_6_ITU does Sum::Marshal::Bits[ :reflect ] { }
my CRC6ITU $itu6 .= new();
is +$itu6.finalize(0x31..0x39), 0x6, "CRC_6_ITU gives expected results";
ok $itu6.check(False,True,True,False,False,False), "CRC_6_ITU self-verifies (0)";

class CRC7JEDEC does Sum::CRC_7_JEDEC does Sum::Marshal::Bits { }
my CRC7JEDEC $j7 .= new();
is +$j7.finalize(0x31..0x39), 0x75, "CRC_7_JEDEC gives expected results";
ok $j7.check(True xx 3, False, True, False, True), "CRC_7_JEDEC self-verifies (0)";

class CRC7ROHC does Sum::CRC_7_ROHC does Sum::Marshal::Bits[ :reflect ] { }
my CRC7ROHC $r7 .= new();
is +$r7.finalize(0x31..0x39), 0x53, "CRC_7_ROHC gives expected results";
is $r7.buf8.gist, buf8.new(0x53).gist, "buf8 works on 7 column CRC";
is $r7.buf1.values, "1 0 1 0 0 1 1", "buf1 works on 7 column CRC";
is $r7.Buf.values, "1 0 1 0 0 1 1", "Buf returns buf1";
ok $r7.check(True,True,False,False,True,False,True), "CRC_7_ROHC self-verifies (0)";

#class CRC7 does Sum::CRC_7 does Sum::Marshal::Bits[ ] { }
#is +CRC7.new().finalize(0x48,0,0,1,0xaa), 0x43, "CRC_7 gives expected result.";

class CRC8CCITT does Sum::CRC_8_CCITT does Sum::Marshal::Bits { }
my CRC8CCITT $cc8 .= new();
is +$cc8.finalize(0x31..0x39), 0xf4, "CRC_8_CCITT gives expected results";
ok $cc8.check(0xf4), "CRC_8_CCITT self-verifies (0)";

class CRC8DARC does Sum::CRC_8_DARC does Sum::Marshal::Bits[ :reflect ] { }
my CRC8DARC $d8 .= new();
is +$d8.finalize(0x31..0x39), 0x15, "CRC_8_DARC gives expected results";
ok $d8.check(0x15), "CRC_8_DARC self-verifies (0)";

class CRC8EBU does Sum::CRC_8_EBU does Sum::Marshal::Bits[ :reflect ] { }
my CRC8EBU $e8 .= new();
is +$e8.finalize(0x31..0x39), 0x97, "CRC_8_EBU gives expected results";
ok $e8.check(0x97), "CRC_8_EBU self-verifies (0)";

class CRC8ICODE does Sum::CRC_8_I_CODE does Sum::Marshal::Bits { }
my CRC8ICODE $ic8 .= new();
is +$ic8.finalize(0x31..0x39), 0x7e, "CRC_8_ICODE gives expected results";
ok $ic8.check(0x7e), "CRC_8_ICODE self-verifies (0)";

class CRC8ITU does Sum::CRC_8_ITU does Sum::Marshal::Bits { }
my CRC8ITU $itu8 .= new();
is +$itu8.finalize(0x31..0x39), 0xa1, "CRC_8_ITU gives expected results";
ok +$itu8.finalize(0xa1), "CRC_8_ITU self-verifies (0)";

class CRC81W does Sum::CRC_8_1_Wire does Sum::Marshal::Bits[ :reflect ] { }
my CRC81W $ow8 .= new();
is +$ow8.finalize(0x31..0x39), 0xa1, "CRC_8_1_Wire gives expected results";
ok $ow8.check(0xa1), "CRC_8_1_Wire self-verifies (0)";

class CRC8ROHC does Sum::CRC_8_ROHC does Sum::Marshal::Bits[ :reflect ] { }
my CRC8ROHC $r8 .= new();
is +$r8.finalize(0x31..0x39), 0xd0, "CRC_8_ROHC gives expected results";
ok $r8.check(0xd0), "CRC_8_ROHC self-verifies (0)";

class WCDMA does Sum::CRC_8_WCDMA does Sum::Marshal::Bits[ :reflect ] { }
given WCDMA.new {
  is +.finalize(0x31..0x39), 0x25, "CRC_8_WCDMA gives expected results";
  ok .check(0x25), "CRC_8_WCDMA self-verifies (0)";
}

class SAE does Sum::CRC_8_SAE_J1850 does Sum::Marshal::Bits[ ] { }
given SAE.new {
  is +.finalize(0x31..0x39), 0x4b, "CRC_8_SAE_J1850 gives expected value";
  ok .check(0x4b), "CRC_8_SAE_J1850 self-verifies (residual)";
}

class AU does Sum::CRC_8_AUTOSAR does Sum::Marshal::Bits[ ] { }
given AU.new {
  is +.finalize(0x31..0x39), 0xdf, "CRC_8_AUTOSAR gives expected value";
  is .buf8.gist, buf8.new(0xdf).gist, "buf8 works on 8 column CRC";
  ok .check(0xdf), "CRC_8_AUTOSAR self-verifies (residual)";
}

class AAL does Sum::CRC_10_AAL does Sum::Marshal::Bits[ ] { }
given AAL.new {
  is +.finalize(0x31..0x39), 0x199, "CRC_10_AAL gives expected value";
  ok .check(False,True,0x99), "CRC_10_AAL self-verifies (0)";
}

class FR does Sum::CRC_11_FlexRay does Sum::Marshal::Bits[ ] { }
given FR.new {
  is +.finalize(0x31..0x39), 0x5a3, "CRC_11_FlexRay gives expected value";
  ok .check(True,False,True,0xa3), "CRC_11_FlexRay self-verifies (0)";
}

class G3 does Sum::CRC_12_3GPP does Sum::Marshal::Bits[ ] { }
given G3.new {
  is +.finalize(0x31..0x39), 0xdaf, "CRC_12_3GPP gives expected value";
  ok .check(0xf5,True,False,True,True), "CRC_12_3GPP self-verifies (0)";
}

class D12 does Sum::CRC_12_DECT does Sum::Marshal::Bits[ ] { }
given D12.new {
  is +.finalize(0x31..0x39),0xf5b, "CRC_12_DECT gives expected value";
  ok .check(True xx 4,0x5b), "CRC_12_DECT self-verifies (0)";
}

class D14 does Sum::CRC_14_DARC does Sum::Marshal::Bits[ :reflect ] { }
given D14.new {
  is +.finalize(0x31..0x39),0x082d, "CRC_14_DARC gives expected value";
  ok .check(0x2d,?<<comb(/./,"000100")), "CRC_14_DARC self-verifies (0)";
}

class C15 does Sum::CRC_15_CAN does Sum::Marshal::Bits[ ] { }
given C15.new {
  is +.finalize(0x31..0x39),0x059e, "CRC_15_CAN gives expected value";
  is .buf8.gist, buf8.new(5,0x9e).gist, "buf8 works on 15 column CRC";
  ok .check(False xx 4,True,False,True,0x9e), "CRC_15_CAN self-verifies (0)";
}

class M15 does Sum::CRC_15_MPT1327 does Sum::Marshal::Bits[ ] { }
given M15.new {
  is +.finalize(0x31..0x39),0x2566, "CRC_15_MPT1327 gives expected value";
  ok .check(?<<comb(/./,"0100101"),0x66), "CRC_15_MPT1327 self-verifies (residual)";
}

class A16 does Sum::CRC_16_ANSI does Sum::Marshal::Bits[ ] { }
given A16.new {
  is +.finalize(0x31..0x39), 0xfee8, "CRC_16_ANSI gives expected value";
  ok .check(0xfe,0xe8), "CRC_16_ANSI self-verifies (0)";
}

class L16 does Sum::CRC_16_LHA does Sum::Marshal::Bits[ :reflect ] { }
given L16.new {
  is +.finalize(0x31..0x39), 0xbb3d, "CRC_16_LHA gives expected value";
  ok .check(0x3d,0xbb), "CRC_16_LHA self-verifies (0)";
}

# Test sum and value from "CYCLIC REDUNDANCY CHECKS IN USB" crcdes.pdf usb.org
class USB16 does Sum::CRC_16_USB_WIRE does Sum::Marshal::Bits[ :bits(16) ] { }
given USB16.new {
  my $s = .finalize(?<<(+<<comb(/./,11000100101000101110011010010001)));
  is +$s, 0x7038, "CRC_16_USB_WIRE gives expected results";
  ok .check(+$s), "CRC_16_USB_WIRE self-verifies (residual)";
}

class USB16_2 does Sum::CRC_16_USB does Sum::Marshal::Bits[ :reflect ] { }
given USB16_2.new {
  is +.finalize(0x31..0x39), 0xb4c8, "CRC_16_USB gives expected value";
  ok .check(0xc8,0xb4), "CRC_16_USB self-verifies (residual)";
}

class OW16 does Sum::CRC_16_1_Wire does Sum::Marshal::Bits[ :reflect ] { }
given OW16.new {
  is +.finalize(0x31..0x39), 0x44c2, "CRC_16_1_Wire gives expected value";
  ok .check(0x44,0xc2), "CRC_16_1_Wire self-verifies (residual)";
}

class MB16 does Sum::CRC_16_Modbus does Sum::Marshal::Bits[ :reflect ] { }
given MB16.new {
  is +.finalize(0x31..0x39), 0x4b37, "CRC_16_Modbus gives expected result.";
  ok .check(0x37,0x4b), "CRC_16_Modbus self-verifies (0)";
}

class DD16 does Sum::CRC_16_DDS_110 does Sum::Marshal::Bits[ ] { }
given DD16.new {
  is +.finalize(0x31..0x39), 0x9ecf, "CRC_16_DDS_110 gives expected result.";
  ok .check(0x9e,0xcf), "CRC_16_DDS_110 self-verifies (0)";
}

class X16 does Sum::CRC_16_X25 does Sum::Marshal::Bits[ :reflect ] { }
given X16.new {
  is +.finalize(0x31..0x39), 0x906e, "CRC_16_X25 gives expected result.";
  ok .check(0x6e,0x90), "CRC_16_X25 self-verifies (0)";
}

class EP16 does Sum::CRC_16_EPC does Sum::Marshal::Bits[ ] { }
given EP16.new {
  is +.finalize(0x31..0x39), 0xd64e, "CRC_16_EPC gives expected result.";
  ok .check(0xd6,0x4e), "CRC_16_EPC self-verifies (0)";
}
# Tests from "Specification for RFID Air Interface" Version 1.2.0 EPCGlobal
class EP16_16 does Sum::CRC_16_EPC does Sum::Marshal::Bits[ :bits(16) ] { }
given EP16_16.new {
  is +.finalize(0x3000,0x1111,0x2222,0x3333,0x4444,0x5555,0x6666), 0x1835, "CRC_16_EPC (16-bit addends) gives expected results.";
  ok .check(0x1835), "CRC_16_EPC (16-bit-addends) self-verifies (residual)";
}

# Tested using linux kernel lib/crc-itu-t.c (misnamed therein).
class CCITT does Sum::CRC_16_CCITT_TRUE does Sum::Marshal::Bits[ :reflect ] { }
given CCITT.new {
  is +.finalize("Please to checksum this text".ords), 0x9e53, "CRC_16_CCITT_TRUE gives expected result.";
  ok .check(0x53, 0x9e), "CRC_16_CCITT_TRUE self-verifies (0)";
}

class XM16 does Sum::CRC_16_XModem does Sum::Marshal::Bits[ ] { }
given XM16.new {
  is +.finalize(0x31..0x39), 0x31c3, "CRC_16_XModem gives expected result.";
  ok .check(0x31,0xc3), "CRC_16_XModem self-verifies (0)";
}

class MC16 does Sum::CRC_16_MCRF does Sum::Marshal::Bits[ :reflect ] { }
given MC16.new {
  is +.finalize(0x31..0x39), 0x6f91, "CRC_16_MCRF gives expected result.";
  is .buf8.gist, buf8.new(0x6f,0x91).gist, "buf8 works on 16 column CRC";
  ok .check(0x91, 0x6f), "CRC_16_MCRF self-verifies (0)";
}

# Test value taken from AUTOSAR document (see references)
class AU2 does Sum::CRC_16_CCITT_FALSE does Sum::Marshal::Bits[ ] { }
given AU2.new {
  is +.finalize(0x31..0x39), 0x29b1, "CRC_16_CCITT_FALSE gives expected value";
  ok .check(0x29, 0xb1), "CRC_16_CCITT_FALSE self-verifies (0)";
}

class DN16 does Sum::CRC_16_DNP does Sum::Marshal::Bits[ :reflect ] { }
given DN16.new {
  is +.finalize(0x31..0x39), 0xea82, "CRC_16_DNP gives expected result.";
  ok .check(0x82, 0xea), "CRC_16_DNP self-verifies (0)";
}

class EN16 does Sum::CRC_16_EN_13757 does Sum::Marshal::Bits[ ] { }
given EN16.new {
  is +.finalize(0x31..0x39), 0xc2b7, "CRC_16_EN13757 gives expected result.";
  ok .check(0xc2, 0xb7), "CRC_16_EN13757 self-verifies (0)";
}

class T16 does Sum::CRC_16_T10_DIF does Sum::Marshal::Bits[ ] { }
given T16.new {
  is +.finalize(0x31..0x39), 0xd0db, "CRC_16_T10_DIF gives expected result.";
  ok .check(0xd0, 0xdb), "CRC_16_T10_DIF self-verifies (0)";
}

class TE16 does Sum::CRC_16_Teledisk does Sum::Marshal::Bits[ ] { }
given TE16.new {
  is +.finalize(0x31..0x39), 0x0fb3, "CRC_16_Teledisk gives expected result.";
  ok .check(0x0f, 0xb3), "CRC_16_Teledisk self-verifies (0)";
}

# Need independent test vector for this
#class AR16 does Sum::CRC_16_ARINC does Sum::Marshal::Bits[ ] { }
#given AR16.new {
#  is +.finalize(0x31..0x39), 0xXXXX, "CRC_16_ARINC gives expected result.";
#  ok .check(0xXX, 0xXX), "CRC_16_ARINC self-verifies (0)";
#}

class PGP does Sum::CRC_24_PGP does Sum::Marshal::Bits[ ] { }
my PGP $pgp .= new();
is +$pgp.finalize(0x31..0x39), 0x21cf02, "CRC_24_PGP gives expected value";
is $pgp.buf8.gist, buf8.new(0x21,0xcf,2).gist, "buf8 works on 24 column CRC";
ok $pgp.check(0x21,0xcf,0x02), "CRC_24_PGP self-verifies (0)";

class CRC32 does Sum::CRC_32 does Sum::Marshal::Bits[ :bits(32) :reflect ]
                does Sum::Marshal::Bits[ :accept(Str) :bits(8) :reflect ] {

    multi method marshal ( $addend ) is default { $addend }
    multi method marshal (*@addends) is default {
        return ( for @addends { self.marshal($_) } )
    }
}
$s = CRC32.new();
$i = +$s.finalize("65","66","67","68","69","70","71","72"); # "ABCDEFGH"
is $i, 0x68dcb61c, "CRC_32 gives expected result.";
ok $s.check($i), "CRC_32 self-verifies (residual)";

class BZ2 does Sum::CRC_32_BZ2 does Sum::Marshal::Bits[ ] { }
my BZ2 $bz2 .= new();
is +$bz2.finalize(0x31..0x39), 0xfc891918, "CRC_32_BZ2 gives expected value";
ok $bz2.check(0xfc,0x89,0x19,0x18), "CRC_32_BZ2 self-verifies (residual)";

class C32 does Sum::CRC_32C does Sum::Marshal::Bits[ :reflect ] { }
my C32 $c32 .= new();
is +$c32.finalize(0x31..0x39), 0xe3069283, "CRC_32C gives expected value";
is $c32.buf8.gist, buf8.new(0xe3,6,0x92,0x83).gist, "buf8 works on 32 column CRC";
ok $c32.check(0x83,0x92,0x06,0xe3), "CRC_32C self-verifies (residual)";

class D32 does Sum::CRC_32D does Sum::Marshal::Bits[ :reflect ] { }
my D32 $d32 .= new();
is +$d32.finalize(0x31..0x39), 0x87315576, "CRC_32D gives expected value";
ok $d32.check(0x76,0x55,0x31,0x87), "CRC_32D self-verifies (residual)";

class MP2 does Sum::CRC_32_MPEG2 does Sum::Marshal::Bits[ ] { }
my MP2 $mp2 .= new();
is +$mp2.finalize(0x31..0x39), 0x0376e6e7, "CRC_32_MPEG2 gives expected value";
ok $mp2.check(0x03,0x76,0xe6,0xe7), "CRC_32_MPEG2 self-verifies (0)";

class Q32 does Sum::CRC_32Q does Sum::Marshal::Bits[ ] { }
my Q32 $q32 .= new();
is +$q32.finalize(0x31..0x39), 0x3010bf7f, "CRC_32Q gives expected value";
ok $q32.check(0x30,0x10,0xbf,0x7f), "CRC_32Q self-verifies (0)";

class XFER does Sum::CRC_32_XFER does Sum::Marshal::Bits[ ] { }
my XFER $x32 .= new();
is +$x32.finalize(0x31..0x39), 0xbd0be338, "CRC_32_XFER gives expected value";
ok $x32.check(0xbd,0x0b,0xe3,0x38), "CRC_32_XFER self-verifies (0)";

class GSM40 does Sum::CRC_40_GSM does Sum::Marshal::Bits[ ] { }
my GSM40 $g40 .= new();
is +$g40.finalize(0x31..0x39), 0x2be9b039b9, "CRC_40_GSM gives expected value";
ok $g40.check(0x2b,0xe9,0xb0,0x39,0xb9), "CRC_40_GSM self-verifies (0)";

class ISO64 does Sum::CRC_64_ISO does Sum::Marshal::Bits[ :reflect ] { }
my ISO64 $i64 .= new();
is +$i64.finalize(0x31..0x39), 0x46a5a9388a5beffe, "CRC_64_ISO gives expected value";
ok $i64.check(reverse(0x46,0xa5,0xa9,0x38,0x8a,0x5b,0xef,0xfe)), "CRC_64_ISO self-verifies (0)";

class DLT64 does Sum::CRC_64_DLT does Sum::Marshal::Bits[ ] { }
my DLT64 $d64 .= new();
is +$d64.finalize(0x31..0x39), 0x6c40df5f0b497347, "CRC_64_DLT gives expected value";
ok $d64.check(0x6c,0x40,0xdf,0x5f,0x0b,0x49,0x73,0x47), "CRC_64_DLT self-verifies (0)";

class Jones does Sum::CRC_64_Jones does Sum::Marshal::Bits[ :reflect ] { }
my Jones $j64 .= new();
is +$j64.finalize(0x31..0x39), 0xCAA717168609F281, "CRC_64_Jones gives expected value";
ok $j64.check(reverse(0xca,0xa7,0x17,0x16,0x86,0x09,0xf2,0x81)), "CRC_64_Jones self-verifies (0)";

class XZ does Sum::CRC_64_XZ does Sum::Marshal::Bits[ :reflect ] { }
my XZ $xz64 .= new();
is +$xz64.finalize(0x31..0x39), 0x995dc9bbdf1939fa, "CRC_64_XZ gives expected value";
is $xz64.buf8.gist, buf8.new(0x99,0x5d,0xc9,0xbb,0xdf,0x19,0x39,0xfa).gist, "buf8 works on 64 column CRC";
ok $xz64.check(reverse(0x99,0x5d,0xc9,0xbb,0xdf,0x19,0x39,0xfa)), "CRC_64_XZ self-verifies (residual)";

class DARC does Sum::CRC_82_DARC does Sum::Marshal::Bits[ :reflect ] { }
my DARC $d82 .= new();
is +$d82.finalize(0x31..0x39), 0x09ea83f625023801fd612, "CRC_82_DARC gives expected value";
is $d82.buf8.gist, buf8.new(0,0x9e,0xa8,0x3f,0x62,0x50,0x23,0x80,0x1f,0xd6,0x12).gist, "buf8 works on 82 column CRC";
ok $d82.check(reverse(0x9e,0xa8,0x3f,0x62,0x50,0x23,0x80,0x1f,0xd6,0x12), False, False), "CRC_82_DARC self-verifies (0)";
