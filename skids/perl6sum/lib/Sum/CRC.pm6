
use Sum;

=NAME Sum::CRC - Cyclic Redundancy Checksum roles for Sum::

=begin DESCRIPTION
    The C<Sum::CRC> module provides roles for generating types of C<Sum>
    that calculate a cyclic redundancy checksum.  Many subroles are provided
    for convenient access to well-standardized CRC parameter sets.

    The base C<Sum::CRC> role variant is a bitwise implementation which
    focuses on versatility.  Based on the parameters used, alternate optimized
    implementations may be composed instead (when they are eventually
    implemented.)  In some cases, forcing the use of optimizations may
    require providing additional parameters.
=end DESCRIPTION

=begin pod

=head1 ROLES

=head2 role Sum::CRC [ :@header?, :@footer?, :$residual = 0,
                       :$iniv = Bool::False, :$finv = Bool::False,
                       :$columns = 8, :$poly, :$reflect = Bool::False ]
            does Sum

    The C<Sum::CRC> parametric role is used to create a type of C<Sum>
    that calculates a particular kind of cyclic redundancy checksum
    based on the provided parameters.  The resulting C<Sum> expects
    single bit addends and will simply check the truth value of each
    provided addend, unless a C<Sum::Marshal> role is mixed in.

    The C<$columns> parameter specifies the number of bits in the final
    checksum, and thus also the number of bits in many of the other
    parameters.

    The C<$poly> parameter defines the generator polynomial.  The
    format should be an integer where each bit represents a coefficient,
    least significant coefficient mapped to least significant bit, with the
    most significant term's coefficient truncated.  The most significant
    term is deduced from C<$columns> and is assumed to have a coefficient
    of 1.  This is sometimes called the "MSB-first code" or "normal code"
    for a generator polynomial.

    When C<:reflect> is specified, the remainder is swabbed bitwise
    to produce final results.  To swab input addends, mix in
    appropriate C<Sum::Marshal> role(s) such as a C<Sum::Marshal::Bits>.

    When C<:finv> is specified, the final result is bitwise inverted.
    When a non-boolean value is specified for C<$finv>, the remainder
    and this value are combined in a bitwise XOR when a result is
    finalized.  This happens after C<:reflect> swabbing, if any.

    When C<:iniv> is specified, the remainder is set to all 1s at the
    start of the checksum.  When a non-boolean value is specified for
    C<$iniv>, the remainder is initialized to the provided value.
    This value is not adjusted to accomodate any C<:reflect> swabbing.

    Note that a non-boolean value passed in C<:iniv> is assigned directly
    to the remainder, which is not a typed attribute, so the value type is
    assigned along with the value.  This is left this way to provide
    optimization flexibility, but is a potential gotcha if one were to
    provide a type narrower than C<$columns> bits or which does not support
    the required bitwise operations.  Likewise a non-boolean value
    provided in C<:finv> is used directly.  When in doubt, coerce such
    values to Int.

    When C<@header> is provided, the addends it contains are provided
    to the sum immediately upon initialization, after the remainder
    is initialized according to the value of C<$iniv>.  When C<@footer>
    is provided, the addends it contains are provided to the sum before
    a final result is produced.  As partial sums are supported, the
    remainder is then restored such that more addends may be provided.
    Both C<@header> and C<@footer> are subject to the same marshalling
    as provided by any C<Sum::Marshal> roles for normal addends.

    The C<$residual> parameter is used in the C<.check> method, described
    below.

=head2 METHODS

=head3 method check(*@addends)

    The check method is intended to be used when verifying data
    that includes an embedded precaculated CRC, such that the
    sum of the original data and the CRC should produce a constant.

    This method simply calls C<.finalize> and, if that succeeds,
    returns C<True> if the resulting value is the same as the value
    provided to the role in the C<$residual> role parameter.

=end pod

role Sum::CRC [ :@header?, :@footer?, :$residual = 0,
                :$iniv = Bool::False, :$finv = Bool::False,
                :$columns = 8, :$poly, :$reflect = Bool::False ]
     does Sum {

    my Int $mask = :2[1 xx $columns];

    has Int $.rem is rw = ($iniv.WHAT === Bool) ?? (-$iniv +& $mask) !! +$iniv;

    method size ( --> int) { +$columns }

    method add (*@addends) {
        for (@addends) -> $a {
            my $b = $.rem +& (1 +< ($columns - 1));
            $.rem +<= 1;
	    $.rem +&= $mask;
            $.rem +^= $poly if $a xor $b;
        }
        return;
    };

    method finalize(*@addends) {
        self.push(@addends);
        my $rev = $.rem;
        if +@footer {
            my $c = self.clone();
	    $c.push(@footer);
	    $rev = $c.rem;
        }
        if $reflect {
            my $rev2 = $rev +& 0; # Think types.
	    for (1 X+< ^$columns) {
                $rev2 +<= 1;
	        $rev2 +|= 1 if $rev +& $_;
	    }
            $rev = $rev2;
        }
        if $finv {
           return $rev +^ $mask if $finv.WHAT === Bool;
           return $rev +^ +$finv;
        }
        return $rev;
    }

    method Numeric () { self.finalize };

    method buf8 () {
        my $bytes = ($columns + 7) div 8;
        buf8.new(self.finalize X+> ($bytes*8-8,{$_-8}...0));
    }
    method buf1 () {
        Buf.new( 1 X+& (self.finalize X+> ($columns-1...0)) );
    }
    method Buf () { self.buf1; }

    method check(*@addends) {
        given self.finalize(@addends) {
	    when Failure { return $_ };
	    default { return so $_ == $residual };
	}
    }
}

=begin pod

=head1 CONVENIENCE ROLES

    The following additional roles may be used to quickly create
    classes that implement published CRC standards.  Note that
    there are cases where different CRC parameters have been
    mistakenly called by the same name.  Also note that a given
    set of CRC parameters may be known by many names.  These
    roles are named to be unambiguous, even when an alternative
    name may be more famous.

    No complete list of names for different parameter sets is
    offered by C<Sum::CRC>.  For that, please consult the references
    below.

=end pod

=begin pod

=head2 role Sum::CRC_3_ROHC
       does Sum::CRC[ :iniv :reflect :columns(3) :poly(0x3) ]

    Implements a 3-bit CRC used in RFC 3095 header compression.

=end pod

role Sum::CRC_3_ROHC
    does Sum::CRC[ :iniv :reflect :columns(3) :poly(0x3) ] { }

=begin pod

=head2 role Sum::CRC_4_ITU
       does Sum::CRC[ :reflect :columns(4) :poly(0x3) ]

    Implements a 4-bit CRC used in ITU G.704

=end pod

role Sum::CRC_4_ITU
    does Sum::CRC[ :reflect :columns(4) :poly(0x3) ] { }

=begin pod

=head2 role Sum::CRC_5_EPC
       does Sum::CRC[ :iniv(9) :columns(5) :poly(0x9) ]

    Implements a 5-bit CRC used in RFID.

=end pod

role Sum::CRC_5_EPC
    does Sum::CRC[ :iniv(9) :columns(5) :poly(0x9) ] { }

=begin pod

=head2 role Sum::CRC_5_ITU
       does Sum::CRC[ :reflect :columns(5) :poly(0x15) ]

    Implements a 5-bit CRC used in ITU G.704

=end pod

role Sum::CRC_5_ITU
    does Sum::CRC[ :reflect :columns(5) :poly(0x15) ] { }

=begin pod

=head2 role Sum::CRC_5_USB
       does Sum::CRC[ :iniv :finv :columns(5) :poly(0x5) :residual(0x13) ]

    Implements a 5-bit CRC used in the USB protocol.

=end pod

role Sum::CRC_5_USB
    does Sum::CRC[ :iniv :finv :columns(5) :poly(0x5) :residual(0x13) ] { }

=begin pod

=head2 role Sum::CRC_6_DARC
       does Sum::CRC[ :reflect :columns(6) :poly(0x19) ]

    Implements a 6-bit CRC used in the DARC radio protocol.

=end pod

role Sum::CRC_6_DARC
    does Sum::CRC[ :reflect :columns(6) :poly(0x19) ] { }

=begin pod

=head2 role Sum::CRC_6_ITU
       does Sum::CRC[ :reflect :columns(6) :poly(0x3) ]

    Implements a 6-bit CRC used in ITU G.704

=end pod

role Sum::CRC_6_ITU
    does Sum::CRC[ :reflect :columns(6) :poly(0x3) ] { }

=begin pod

=head2 role Sum::CRC_7_JEDEC
       does Sum::CRC[ :columns(7) :poly(0x9) ]

    Implements a 7-bit CRC used in JEDEC multimedia cards.

=end pod

role Sum::CRC_7_JEDEC
    does Sum::CRC[ :columns(7) :poly(0x9) ] { }

=begin pod

=head2 role Sum::CRC_7_ROHC
       does Sum::CRC[ :reflect :iniv :columns(7) :poly(0x4f) ]

    Implements a 7-bit CRC used in RFC 3095 header compression.

=end pod

role Sum::CRC_7_ROHC
    does Sum::CRC[ :reflect :iniv :columns(7) :poly(0x4f) ] { }

=begin pod

=head2 role Sum::CRC_8_CCITT
       does Sum::CRC[ :columns(8) :poly(0x7) ]

    Implements a standardized 8-bit CRC used e.g. in SmBus.

=end pod

role Sum::CRC_8_CCITT
    does Sum::CRC[ :columns(8) :poly(0x7) ] { }

=begin pod

=head2 role Sum::CRC_8_DARC
    does Sum::CRC[ :reflect :columns(8) :poly(0x39) ]

    Implements an 8-bit CRC used in the DARC radio protocol.

=end pod

role Sum::CRC_8_DARC
    does Sum::CRC[ :reflect :columns(8) :poly(0x39) ] { }

=begin pod

=head2 role Sum::CRC_8_EBU
       does Sum::CRC[ :reflect :iniv :columns(8) :poly(0x1d) ]

    Implements an 8-bit CRC used in european digital audio

=end pod
role Sum::CRC_8_EBU
    does Sum::CRC[ :reflect :iniv :columns(8) :poly(0x1d) ] { }

=begin pod

=head2 role Sum::CRC_8_I_CODE
       does Sum::CRC[ :iniv(0xfd) :columns(8) :poly(0x1d) ]

    Implements an 8-bit CRC used in I-CODE labels.

=end pod

role Sum::CRC_8_I_CODE
    does Sum::CRC[ :iniv(0xfd) :columns(8) :poly(0x1d) ] { }

=begin pod

=head2 role Sum::CRC_8_ITU
       does Sum::CRC[ :finv(0x55) :columns(8) :poly(0x7) :residual(0xf9) ]

    Implements an 8-bit CRC used in ATM HEC codes.

=end pod

role Sum::CRC_8_ITU
    does Sum::CRC[ :finv(0x55) :columns(8) :poly(0x7) :residual(0xf9) ] { }

=begin pod

=head2 role Sum::CRC_8_1_Wire
       does Sum::CRC[ :reflect :columns(8) :poly(0x31) ]

    Implements an 8-bit CRC used in the 1-Wire bus standard.

=end pod

role Sum::CRC_8_1_Wire
    does Sum::CRC[ :reflect :columns(8) :poly(0x31) ] { }

=begin pod

=head2 role Sum::CRC_8_ROHC
    does Sum::CRC[ :reflect :iniv :columns(8) :poly(0x7) ]

    Implements an 8-bit CRC used in RFC 3095 header compression.

=end pod

role Sum::CRC_8_ROHC
    does Sum::CRC[ :reflect :iniv :columns(8) :poly(0x7) ] { }

=begin pod

=head2 role Sum::CRC_8_WCDMA
       does Sum::CRC[ :reflect :columns(8) :poly(0x9b) ]

    Implements an 8-bit CRC used in WCDMA wireless protocol.

=end pod

role Sum::CRC_8_WCDMA
    does Sum::CRC[ :reflect :columns(8) :poly(0x9b) ] { }

=begin pod

=head2 role Sum::CRC_8_SAE_J1850
       does Sum::CRC[ :iniv :finv :columns(8) :poly(0x1d) :residual(0x3b) ]

    Implements an 8-bit CRC used on the SAE J1850 automotive data bus.

=end pod
# Note that the AUTOSAR document incorrectly says :iniv(0), :finv(0) but
# then it goes on to give a test vector that is valid when :iniv, :finv
role Sum::CRC_8_SAE_J1850
    does Sum::CRC[ :iniv :finv :columns(8) :poly(0x1d) :residual(0x3b) ] { }

=begin pod

=head2 role Sum::CRC_8_AUTOSAR
       does Sum::CRC[ :iniv :finv :columns(8) :poly(0x2f) :residual(0xbd) ]

    Implements an 8-bit CRC used in automotive applications.

=end pod
role Sum::CRC_8_AUTOSAR
    does Sum::CRC[ :iniv :finv :columns(8) :poly(0x2f) :residual(0xbd) ] { }

# Koopman suggestion.  Need to look for test vectors / 3rd party implementation
#role Sum::CRC_8K
#    does Sum::CRC[ :columns(8) :poly(0xd5) ] { }

=begin pod

=head2 role Sum::CRC_10_AAL
    does Sum::CRC[ :columns(10) :poly(0x233) ]

    Implements a 10-bit CRC used in ATM AAL 3/4.

=end pod

role Sum::CRC_10_AAL
    does Sum::CRC[ :columns(10) :poly(0x233) ] { }


=begin pod

=head2 role Sum::CRC_11_FlexRay
    does Sum::CRC[ :iniv(0x1a) :columns(11) :poly(0x385) ]

    Implements an 11-bit CRC used in FlexRay automotive systems.

=end pod

role Sum::CRC_11_FlexRay
    does Sum::CRC[ :iniv(0x1a) :columns(11) :poly(0x385) ] { }

=begin pod

=head2 role Sum::CRC_12_3GPP
    does Sum::CRC[ :reflect :columns(12) :poly(0x80f) ]

    Implements a 12-bit CRC used in 3G mobile systems.

=end pod

role Sum::CRC_12_3GPP
    does Sum::CRC[ :reflect :columns(12) :poly(0x80f) ] { }

=begin pod

=head2 role Sum::CRC_12_DECT
    does Sum::CRC[ :columns(12) :poly(0x80f) ]

    Implements a 12-bit CRC used in Digital Enhanced Cordless
    Telecommunications.

=end pod

role Sum::CRC_12_DECT
    does Sum::CRC[ :columns(12) :poly(0x80f) ] { }

=begin pod

=head2 role Sum::CRC_14_DARC
    does Sum::CRC[ :reflect :columns(14) :poly(0x805) ]

    Implements a 14-bit CRC used in Digital Radio Communications.

=end pod

role Sum::CRC_14_DARC
    does Sum::CRC[ :reflect :columns(14) :poly(0x805) ] { }

=begin pod

=head2 role Sum::CRC_15_CAN
    does Sum::CRC[ :columns(15) :poly(0x4599) ]

    Implements a 15-bit CRC used in the Controller Area Network protocol.

=end pod

role Sum::CRC_15_CAN
    does Sum::CRC[ :columns(15) :poly(0x4599) ] { }

=begin pod

=head2 role Sum::CRC_15_MPT1327
       does Sum::CRC[ :finv(1) :columns(15) :poly(0x6815) :residual(0x6814)]

    Implements a 15-bit CRC used in MPT1327 mobile communications.

=end pod

role Sum::CRC_15_MPT1327
    does Sum::CRC[ :finv(1) :columns(15) :poly(0x6815) :residual(0x6814) ] { }

=begin pod

=head2 role Sum::CRC_16_ANSI
       does Sum::CRC[ :columns(16) :poly(0x8005) ]

    Implements the ANSI 16-Bit CRC polynomial without any inversion or
    reflection.  Note this will be subject to problems with leading and
    trailing zeros.

=end pod

role Sum::CRC_16_ANSI
    does Sum::CRC[ :columns(16) :poly(0x8005) ] { }

=begin pod

=head2 role Sum::CRC_16_LHA
       does Sum::CRC[ :reflect :columns(16) :poly(0x8005) ]

    Implements a 16-Bit CRC using the ANSI 16-bit polynomial with
    reflection of the result, as used by the lha data compression
    utility.  Note this will be subject to problems with leading
    and trailing zeros.

=end pod

# python mod has 1..9 checksum as 0xbb3d
role Sum::CRC_16_LHA
    does Sum::CRC[ :reflect :columns(16) :poly(0x8005) ] { }

=begin pod

=head2 role Sum::CRC_16_USB
       does Sum::CRC[ :reflect :iniv :finv :columns(16) :poly(0x8005)
                      :residual(0x4ffe) ]

    Implements a 16-bit CRC used in the USB protocol.  The result
    is in host order, reflected from what appears on the wire.

=end pod

# Specs seem perhaps not to agree with :reflect, which is what some sources say
role Sum::CRC_16_USB
    does Sum::CRC[ :reflect :iniv :finv :columns(16) :poly(0x8005)
                   :residual(0x4ffe) ] { }

=begin pod

=head2 role Sum::CRC_16_USB_WIRE
       does Sum::CRC[ :iniv :finv :columns(16) :poly(0x8005)
                      :residual(0x7ff2) ]

    Implements a 16-bit CRC used in the USB protocol.  The result
    is as it appears on the wire, unreflected.

=end pod

# Specs seem perhaps not to agree with :reflect, which is what some sources say
role Sum::CRC_16_USB_WIRE
    does Sum::CRC[ :iniv :finv :columns(16) :poly(0x8005)
                   :residual(0x7ff2) ] { }

=begin pod

=head2 role Sum::CRC_16_1_Wire
       does Sum::CRC[ :finv :reflect :columns(16) :poly(0x8005)
                      :residual(0x8d1d) ]

    Implements an 16-bit CRC used on the 1-Wire bus standard.

=end pod

role Sum::CRC_16_1_Wire
    does Sum::CRC[ :finv :reflect :columns(16) :poly(0x8005)
                   :residual(0x8d1d) ] { }

=begin pod

=head2 role Sum::CRC_16_Modbus
    does Sum::CRC[ :iniv :reflect :columns(16) :poly(0x8005) ]

    Implements a 16-bit CRC used in the Modbus protocol.

=end pod

role Sum::CRC_16_Modbus
    does Sum::CRC[ :iniv :reflect :columns(16) :poly(0x8005) ] { }

=begin pod

=head2 role Sum::CRC_16_DDS_110
    does Sum::CRC[ :iniv(0x800d) :columns(16) :poly(0x8005) ]

    Implements a 16-bit CRC used in the ELV DDS-110 function generator.

=end pod

role Sum::CRC_16_DDS_110
    does Sum::CRC[ :iniv(0x800d) :columns(16) :poly(0x8005) ] { }

=begin pod

=head2 role Sum::CRC_16_X25
       does Sum::CRC[ :reflect :iniv :finv :columns(16) :poly(0x1021)
                      :residual(0xf47) ]

    Implements a 16-bit CRC used in X.25 and other ITU-T standards.
    This is the CCITT polynomial with the usual customary inversions
    that protect against leading and trailing zeros, with bit order
    reflected for use on LSB-first serial lines.

=end pod

role Sum::CRC_16_X25
    does Sum::CRC[ :reflect :iniv :finv :columns(16) :poly(0x1021)
                   :residual(0xf47) ] { }

=begin pod

=head2 role Sum::CRC_16_EPC
       does Sum::CRC[ :iniv :finv :columns(16) :poly(0x1021)
                      :residual(0xe2f0) ]

    Implements a 16-bit CRC used in RFID tags.  It is a modification
    of C<Sum::CRC_16_X25> which does not require bit reflection.

=end pod

role Sum::CRC_16_EPC
    does Sum::CRC[ :iniv :finv :columns(16) :poly(0x1021)
                   :residual(0xe2f0) ] { }

=begin pod

=head2 role Sum::CRC_16_CCITT_TRUE
    does Sum::CRC[ :reflect :columns(16) :poly(0x1021) ]

    Implements a commonly used 16-Bit CRC.  This is version of
    CRC which it is technically correct to call "CRC-16-CCITT",
    though many call other CRCs this, referring only to the polynomial
    in use.  It does not contain inversions, and so does not protect
    against leading and trailing zeros.  It is bit reflected for
    use on LSB-first transmission medium.

=end pod

role Sum::CRC_16_CCITT_TRUE
    does Sum::CRC[ :reflect :columns(16) :poly(0x1021) ] { }

=begin pod

=head2 role Sum::CRC_16_XModem
       does Sum::CRC[ :columns(16) :poly(0x1021) ]

    Implements a 16-bit CRC as used in the XModem protocol.  Note this
    contains no inversions and as such does not protect against leading
    or trailing zeros.  It is a modification of CRC-16-CCITT-TRUE which
    changes only the bit order.

=end pod

role Sum::CRC_16_XModem
    does Sum::CRC[ :columns(16) :poly(0x1021) ] { }

=begin pod

=head2 role Sum::CRC_16_MCRF
       does Sum::CRC[ :reflect :iniv :columns(16) :poly(0x1021) ]

    Implements a 16-bit CRC used by some RFID chipsets.  Note that
    this algorithm does not protect against trailing zeros.

=end pod

role Sum::CRC_16_MCRF
    does Sum::CRC[ :reflect :iniv :columns(16) :poly(0x1021) ] { }

=begin pod

=head2 role Sum::CRC_16_CCITT_FALSE
       does Sum::CRC[ :iniv :columns(16) :poly(0x1021) ]

    Calculates a 16-bit checksum which is in use e.g. in floppy
    disks, but commonly mistaken for C<Sum::CRC_16_CCITT>, which
    is slightly different.  It does not protect against trailing
    zeros.

=end pod

role Sum::CRC_16_CCITT_FALSE
    does Sum::CRC[ :iniv :columns(16) :poly(0x1021) ] { }

# Hold off on these for now.  After we can feed role params down, look at
# how they are used.  The difference between the two may be better
# handled at the instance level.
#role Sum::CRC_16_DECT_R
#    does Sum::CRC[ :finv(1) :columns(16) :poly(0x589) :residual(0x588) ]
#
#role Sum::CRC_16_DECT_X  does Sum::CRC[ :columns(16) :poly(0x589) ] { }

=begin pod

=head2 role Sum::CRC_16_DNP
    does Sum::CRC[ :finv :reflect :columns(16) :poly(0x3d65)
                   :residual(0x993a) ]

    Implements a 16-bit CRC used in automation systems using
    Distributed Network Protocol.

=end pod

role Sum::CRC_16_DNP
    does Sum::CRC[ :finv :reflect :columns(16) :poly(0x3d65)
                   :residual(0x993a) ] { }

=begin pod

=head2 role Sum::CRC_16_EN_13757
       does Sum::CRC[ :finv :columns(16) :poly(0x3d65) :residual(0x5c99) ]

    Implements a 16-bit CRC used in utilities metering.

=end pod

role Sum::CRC_16_EN_13757
    does Sum::CRC[ :finv :columns(16) :poly(0x3d65) :residual(0x5c99) ] { }

=begin pod

=head2 role Sum::CRC_16_T10_DIF
       does Sum::CRC[ :columns(16) :poly(0x8bb7) ]

    Implements a 16-bit CRC used in SCSI.

=end pod

role Sum::CRC_16_T10_DIF
    does Sum::CRC[ :columns(16) :poly(0x8bb7) ] { }

=begin pod

=head2 role Sum::CRC_16_Teledisk
    does Sum::CRC[ :columns(16) :poly(0xa097) ]

    Implements a 16-bit CRC used by Teledisk, DECNET, and other arcana.

=end pod

role Sum::CRC_16_Teledisk
    does Sum::CRC[ :columns(16) :poly(0xa097) ] { }

## =begin pod
##
## =head2 role Sum::CRC_16_ARINC
##       does Sum::CRC[ :columns(16) :poly(0xa02b) ] { }
##
##    Implements a 16-bit CRC used in avionics video applications.
##
## =end pod

# TODO: need to find 3rd party implementation or test vector
#role Sum::CRC_16_ARINC
#    does Sum::CRC[ :columns(16) :poly(0xa02b) ] { }

#role Sum::CRC_24
#    does Sum::CRC[ :columns(24) :poly(0x5d6dcb) ] { }

=begin pod

=head2 role Sum::CRC_24_PGP
       does Sum::CRC[ :iniv(0xb704ce) :columns(24) :poly(0x864cfb) ]

    Implements the CRC defined in PGP RFC 4880.

=end pod

role Sum::CRC_24_PGP
    does Sum::CRC[ :iniv(0xb704ce) :columns(24) :poly(0x864cfb) ] { }

# Hold off on these for now.  After we can feed role params down, look at
# how they are used.  The difference between the two may be better
# handled at the instance level.
#role Sum::CRC_24_FLexray_A
#    does Sum::CRC[ :iniv(0xfedcba) :columns(24) :poly(0x5d6dcb) ] { }
#role Sum::CRC_24_Flexray_B
#    does Sum::CRC[ :iniv(0xabcdef) :columns(24) :poly(0x5d6dcb) ] { }

# cannot find spec for this
#role Sum::CRC_30_CDMA does Sum::CRC[ :columns(30) :poly(0x2030b9c7) ] { }

=begin pod

=head2 role Sum::CRC_32
       does Sum::CRC[ :iniv :finv :reflect :columns(32) :poly(0x4c11db7)
                      :residual(0x2144df1c) ]

    Implements one of the most prevalent 32-bit CRC sums, used in many
    Internet standards.

=end pod

# note python module claims no iniv but has same 1..9 checksum 0xCBF43926
role Sum::CRC_32
    does Sum::CRC[ :iniv :finv :reflect :columns(32) :poly(0x4c11db7)
                   :residual(0x2144df1c) ] { }

=begin pod

=head2 role Sum::CRC_32_IEEE does Sum::CRC_32

    This is just a more specific name for C<Sum::CRC_32>.

=end pod

role Sum::CRC_32_IEEE does Sum::CRC_32 { }

=begin pod

=head2 role Sum::CRC_32C
    does Sum::CRC[ :reflect :iniv :finv :columns(32) :poly(0x1edc6f41)
                   :residual(0x48674bc7) ]

    Implements a 32 bit CRC as used in iSCSI.

=end pod

role Sum::CRC_32C
    does Sum::CRC[ :reflect :iniv :finv :columns(32) :poly(0x1edc6f41)
                   :residual(0x48674bc7) ] { }

=begin pod

=head2 role Sum::CRC_32D
    does Sum::CRC[ :reflect :iniv :finv :columns(32) :poly(0xa833982b)
                   :residual(0xbad8faae) ]

    Implements a 32 bit CRC used in Base91 ASCII armor.

=end pod

role Sum::CRC_32D
    does Sum::CRC[ :reflect :iniv :finv :columns(32) :poly(0xa833982b)
                   :residual(0xbad8faae) ] { }

=begin pod

=head2 role Sum::CRC_32_BZ2
    does Sum::CRC[ :iniv :finv :columns(32) :poly(0x04c11db7)
                   :residual(0x38fb2284) ]

    Implements a 32 bit CRC used e.g. in BZIP2, ATM-AAL5, and DECT.

=end pod

role Sum::CRC_32_BZ2
     does Sum::CRC[ :iniv :finv :columns(32) :poly(0x04c11db7)
                    :residual(0x38fb2284) ] { }

=begin pod

=head2 role Sum::CRC_32_MPEG2
    does Sum::CRC[ :iniv :columns(32) :poly(0x04c11db7) ]

    Implements a 32 bit CRC used in MPEG-2 streams.  Note that this
    CRC does not use a final inversion and is thus vulnerable to the
    insertion of trailing bits.

=end pod

role Sum::CRC_32_MPEG2
     does Sum::CRC[ :iniv :columns(32) :poly(0x04c11db7) ] { }

# CRC_32_POSIX aka cksum todo, needs to count elems and use a length tag

# Koopman suggestion.  Need to look for test vectors / 3rd party implementation
#role Sum::CRC_32K
#    does Sum::CRC[ :columns(32) :poly(0x741b8cd7) ] { }

=begin pod

=head2 role Sum::CRC_32Q
       does Sum::CRC[ :columns(32) :poly(0x814141ab) ]

    Implements the CRC-32Q sum as used in some aviation systems.
    Note this CRC does not include inversions and as such is vulnerable
    to the addition of leading and trailing zeros.

=end pod

role Sum::CRC_32Q
    does Sum::CRC[ :columns(32) :poly(0x814141ab) ] { }

=begin pod

=head2 role Sum::CRC_32_XFER
    does Sum::CRC[ :columns(32) :poly(0xaf) ]

    Implements a CRC used by the XFER serial transfer protocol.
    Note this CRC does not include inversions and as such is vulnerable
    to the addition of leading and trailing zeros.

=end pod

role Sum::CRC_32_XFER
    does Sum::CRC[ :columns(32) :poly(0xaf) ] { }

=begin pod

=head2 role Sum::CRC_40_GSM
    does Sum::CRC[ :columns(40) :poly(0x4820009) ]

    Implements the GSM FIRE code CRC.  Note this CRC does not include
    inversions and as such is vulnerable to the addition of leading
    and trailing zeros.

=end pod

role Sum::CRC_40_GSM
    does Sum::CRC[ :columns(40) :poly(0x4820009) ] { }

=begin pod

=head2 role Sum::CRC_64_ISO
    does Sum::CRC[ :reflect :columns(64) :poly(0x1b) ]

    Implements the ISO 3309 64 bit CRC.  Note this CRC does not include
    inversions and as such is vulnerable to the addition of leading and
    trailing zeros.

=end pod

role Sum::CRC_64_ISO
    does Sum::CRC[ :reflect :columns(64) :poly(0x1b) ] { }

# Need to look for test vectors / 3rd party implementation
# Note: python module claims :!iniv, reveng says :iniv
# 1..9 checksum 0x62EC59E3F1A4F00A
#role Sum::CRC_64_WE
#    does Sum::CRC[ :iniv :finv :columns(64) :poly(0x42f0e1eba9ea3693) ] { }

=begin pod

=head2 role Sum::CRC_64_DLT
    does Sum::CRC[ :columns(64) :poly(0x42f0e1eba9ea3693) ]

    Implements a CRC using the ECMA-182 polynomial as used in DLT-1 tapes.
    Note this CRC does not include inversions and as such is vulnerable
    to the addition of leading and trailing zeros.

=end pod

role Sum::CRC_64_DLT
    does Sum::CRC[ :columns(64) :poly(0x42f0e1eba9ea3693) ] { }

=begin pod

=head2 role Sum::CRC_64_XZ
    does Sum::CRC[ :iniv :finv :reflect :columns(64) :poly(0x42f0e1eba9ea3693)
                   :residual(0xb66a73654282cac0) ]

    Implements a CRC using the ECMA/DLT polynomial as used in the C<.xz>
    file format.  This adds the customary codeword inversions to provide
    protection against leading and trailing zeros, and also reflects the
    input values and codewords.

=end pod

role Sum::CRC_64_XZ
    does Sum::CRC[ :iniv :finv :reflect :columns(64) :poly(0x42f0e1eba9ea3693)
                   :residual(0xb66a73654282cac0) ] { }

=begin pod

=head2 role Sum::CRC_64_Jones
    does Sum::CRC[ :reflect :iniv :columns(64) :poly(0xad93d23594c935a9) ]

    Implements a CRC as proposed in
    http://www.cs.ucl.ac.uk/staff/d.jones/crcnote.pdf.  Note this
    implementation does not include C<:finv> and as such, does not
    use a residual and is thus vulnerable to the addition of trailing zeros.

=end pod

role Sum::CRC_64_Jones
    does Sum::CRC[ :reflect :iniv :columns(64) :poly(0xad93d23594c935a9) ] { }

=begin pod

=head2 role Sum::CRC_82_DARC
    does Sum::CRC[ :reflect :columns(82) :poly(0x0308c0111011401440411) ]

    Implements a CRC used in Digital Radio Communications (DARC).

=end pod

role Sum::CRC_82_DARC
    does Sum::CRC[ :reflect :columns(82) :poly(0x0308c0111011401440411) ] { }

=AUTHOR Brian S. Julin

=COPYRIGHT Copyright (c) 2012 Brian S. Julin. All rights reserved.

=begin LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License 2.0.
=end LICENSE

=begin REFERENCES
=item L<http://reveng.sourceforge.net/crc-catalogue>
=item Python CRC modules L<http://crcmod.sourceforge.net/crcmod.predefined.html>
=item L<http://www.ece.cmu.edu/~koopman/roses/dsn04/koopman04_crc_poly_embedded.pdf>
=item "SAE Standard J1850 Class B Data Communication Network Interface" 2/15/94
=item "Specification of CRC Routines" V3.3.0 R3.2 Rev 2 AUTOSAR document ID 016
=end REFERENCES

=SEE-ALSO C<Sum::(pm3)>

