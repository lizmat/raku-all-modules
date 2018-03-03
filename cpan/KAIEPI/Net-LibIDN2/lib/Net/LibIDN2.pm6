use v6.c;
use NativeCall;
unit class Net::LibIDN2:ver<0.0.1>:auth<github:Kaiepi>;

constant LIB = 'idn2';

sub idn2_check_version(Str --> Str) is native(LIB) { * }

constant IDN2_VERSION        is export = idn2_check_version('');
constant IDN2_VERSION_NUMBER is export = {
    my $digits := IDN2_VERSION.comb(/\d+/).map({ :16($_) });
    given +$digits {
        when 2  { :16(sprintf '%02x%02x0000', $digits) }
        when 3  { :16(sprintf '%02x%02x%04x', $digits) }
    }
}();
constant IDN2_VERSION_MAJOR  is export = IDN2_VERSION_NUMBER +& 0xFF000000 +> 24;
constant IDN2_VERSION_MINOR  is export = IDN2_VERSION_NUMBER +& 0x00FF0000 +> 16;
constant IDN2_VERSION_PATCH  is export = IDN2_VERSION_NUMBER +& 0x0000FFFF;

constant IDN2_LABEL_MAX_LENGTH  is export = 63;
constant IDN2_DOMAIN_MAX_LENGTH is export = 255;

constant IDN2_NFC_INPUT            is export = 1;
constant IDN2_ALABEL_ROUNDTRIP     is export = 2;
constant IDN2_TRANSITIONAL         is export = 4;
constant IDN2_NONTRANSITIONAL      is export = 8;
constant IDN2_ALLOW_UNASSIGNED     is export = 16;
constant IDN2_USE_STD3_ASCII_RULES is export = 32;

constant IDN2_OK                      is export = 0;
constant IDN2_MALLOC                  is export = -100;
constant IDN2_NO_CODESET              is export = -101;
constant IDN2_ICONV_FAIL              is export = -102;
constant IDN2_ENCODING_ERROR          is export = -200;
constant IDN2_NFC                     is export = -201;
constant IDN2_PUNYCODE_BAD_INPUT      is export = -202;
constant IDN2_PUNYCODE_BIG_OUTPUT     is export = -203;
constant IDN2_PUNYCODE_OVERFLOW       is export = -204;
constant IDN2_TOO_BIG_DOMAIN          is export = -205;
constant IDN2_TOO_BIG_LABEL           is export = -206;
constant IDN2_INVALID_ALABEL          is export = -207;
constant IDN2_UALABEL_MISMATCH        is export = -208;
constant IDN2_INVALID_FLAGS           is export = -209;
constant IDN2_NOT_NFC                 is export = -300;
constant IDN2_2HYPHEN                 is export = -301;
constant IDN2_HYPHEN_STARTEND         is export = -302;
constant IDN2_LEADING_COMBINING       is export = -303;
constant IDN2_DISALLOWED              is export = -304;
constant IDN2_CONTEXTJ                is export = -305;
constant IDN2_CONTEXTJ_NO_RULE        is export = -306;
constant IDN2_CONTEXTO                is export = -307;
constant IDN2_CONTEXTO_NO_RULE        is export = -308;
constant IDN2_UNASSIGNED              is export = -309;
constant IDN2_BIDI                    is export = -310;
constant IDN2_DOT_IN_LABEL            is export = -311;
constant IDN2_INVALID_TRANSITIONAL    is export = -312;
constant IDN2_INVALID_NONTRANSITIONAL is export = -313;

sub idn2_free(Pointer[Str]) is native(LIB) { * }

method check_version(Str $version = '' --> Str) {
    # See https://github.com/rakudo/rakudo/issues/1576
    my $v := Version.new($version);
    CATCH { default { return IDN2_VERSION } }
    my $v2 := Version.new(IDN2_VERSION);
    $v > $v2 ?? '' !! IDN2_VERSION;
}

sub idn2_strerror(int32 --> Str) is native(LIB) { * }
method strerror(Int $errno --> Str) { idn2_strerror($errno) }

sub idn2_strerror_name(int32 --> Str) is native(LIB) { * }
method strerror_name(Int $errno --> Str) { idn2_strerror_name($errno) }

sub invoke_native(&idn2, Int $flags, Int $code is rw, *@inputs --> Str) {
    my $output := Pointer[Str].new;
    $code = &idn2(|@inputs, $output, $flags);
    return '' unless $code eq IDN2_OK;

    my $res = $output.deref;
    idn2_free($output);
    $res;
}

sub idn2_lookup_u8(Str, Pointer[Str] is rw, int32 --> int32) is native(LIB) { * }
proto method lookup_u8(Str, Int $?, Int $? --> Str) { * }
multi method lookup_u8(Str $input, Int $flags = 0 --> Str) {
    invoke_native(&idn2_lookup_u8, $flags, my Int $, $input);
}
multi method lookup_u8(Str $input, Int $flags, Int $code is rw --> Str) {
    invoke_native(&idn2_lookup_u8, $flags, $code, $input);
}

sub idn2_register_u8(Str, Str, Pointer[Str] is rw, int32 --> int32) is native(LIB) { * }
proto method register_u8(Str, Str $?, Int $?, Int $? --> Str) { * }
multi method register_u8(Str $uinput, Str $ainput, Int $flags --> Str) {
    invoke_native(&idn2_register_u8, $flags, my Int $, $uinput, $ainput);
}
multi method register_u8(Str $uinput, Str $ainput, Int $flags, Int $code is rw --> Str) {
    invoke_native(&idn2_register_u8, $flags, $code, $uinput, $ainput);
}

=begin pod

=head1 NAME

Net::LibIDN2 - Perl6 bindings for GNU LibIDN2

=head1 SYNOPSIS

=begin code

    use Net::LibIDN2;

    my $idn := Net::LibIDN2.new;

    my Int $code;
    my $lookup := $idn.lookup_u8('test', IDN2_NFC_INPUT, $code);
    say "$lookup $code"; # test 0

    my $result := $idn.register_u8("m\xFC\xDFli", 'xn--mli-5ka8l', IDN2_NFC_INPUT, $code);
    say "$result $code"; # xn--mli-5ka8l 0

    say $idn.strerror($code);      # success
    say $idn.strerror_name($code); # IDN2_OK

=end code

=head1 DESCRIPTION

Net::LibIDN2 is a Perl 6 wrapper for the GNU LibIDN2 library.

=head1 METHODS

=item check_version(Str $version? --> Str)

Compares $version against the version of LibIDN2 installed and returns either
an empty string if $version is greater than the version installed, or
IDN2_VERSION otherwise.

=item strerror(Int $errno --> Str)

Returns the error represented by $errno in human readable form.

=item strerror_name(Int $errno --> Str)

Returns the internal error name of $errno.

=item lookup_u8(Str $input, Int $flags?, Int $code is rw --> Str)

Performs an IDNA2008 lookup string conversion on $input. See RFC 5891, section
5. $input must be a UTF8 encoded string in NFC form if no IDN2_NFC_INPUT flag
is passed.

=item register_u8(Str $uinput, Str $ainput, Int $flags?, Int $code is rw --> Str)

Performs an IDNA2008 register string conversion on $uinput and $ainput. See RFC
5891, section 4. $uinput must be a UTF8 encoded string in NFC form if no
IDN2_NFC_INPUT flag is passed. $ainput must be an ACE encoded string.

=head1 CONSTANTS

=item Int IDN2_LABEL_MAX_LENGTH

The maximum label length.

=item Int IDN2_DOMAIN_MAX_LENGTH

The maximum domain name length.

=head2 VERSIONING

=item Str IDN2_VERSION

The version of LibIDN2 installed.

=item Int IDN2_VERSION_NUMBER

The version of LibIDN2 installed represented as a 32 bit integer. The first
pair of bits represents the major version, the second represents the minor
version, and the last 4 represent the patch version.

=item Int IDN2_VERSION_MAJOR

The major version of LibIDN2 installed.

=item Int IDN2_VERSION_MINOR

The minor version of LidIDN2 installed.

=item Int IDN2_VERSION_PATCH

The patch version of LibIDN2 installed.

=head2 FLAGS

=item Int IDN2_NFC_INPUT

Normalize the input string using the NFC format.

=item Int IDN2_ALABEL_ROUNDTRIP

Perform optional IDNA2008 lookup roundtrip check.

=item Int IDN2_TRANSITIONAL

Perform Unicode TR46 transitional processing.

=item Int IDN2_NONTRANSITIONAL

Perform Unicode TR46 non-transitional processing.

=head2 ERRORS

=item Int IDN2_OK

Success.

=item Int IDN2_MALLOC

Memory allocation failure.

=item Int IDN2_NO_CODESET

Failed to determine a string's encoding.

=item Int IDN2_ICONV_FAIL

Failed to transcode a string to UTF8.

=item Int IDN2_ENCODING_ERROR

Unicode data encoding error.

=item Int IDN2_NFC

Failed to normalize a string.

=item Int IDN2_PUNYCODE_BAD_INPUT

Invalid input to Punycode.

=item Int IDN2_PUNYCODE_BIG_OUTPUT

Punycode output buffer is too small.

=item Int IDN2_PUNYCODE_OVERFLOW

Punycode conversion would overflow.

=item Int IDN2_TOO_BIG_DOMAIN

Domain is larger than IDN2_DOMAIN_MAX_LENGTH

=item Int IDN2_TOO_BIG_LABEL

Label is larger than IDN2_LABEL_MAX_LENGTH

=item Int IDN2_INVALID_ALABEL

Invalid A-label.

=item Int IDN2_UALABEL_MISMATCH

Given U-label and A-label do not match.

=item Int IDN2_INVALID_FLAGS

Invalid combination of flags.

=item Int IDN2_NOT_NFC

String is not normalized in NFC format.

=item Int IDN2_2HYPHEN

String has forbidden two hyphens.

=item Int IDN2_HYPHEN_STARTEND

String has forbidden start/end hyphen.

=item Int IDN2_LEADING_COMBINING

String has forbidden leading combining character.

=item Int IDN2_DISALLOWED

String has disallowed character.

=item Int IDN2_CONTEXTJ

String has forbidden context-j character.

=item Int IDN2_CONTEXTJ_NO_RULE

String has context-j character without any rull.

=item Int IDN2_CONTEXTO

String has forbidden context-o character.

=item Int IDN2_CONTEXTO_NO_RULE

String has context-o character without any rull.

=item Int IDN2_UNASSIGNED

String has forbidden unassigned character.

=item Int IDN2_BIDI

String has forbidden bi-directional properties.

=item Int IDN2_DOT_IN_LABEL

Label has forbidden dot (TR46).

=item Int IDN2_INVALID_TRANSITIONAL

Label has a character forbidden in transitional mode (TR46).

=item Int IDN2_INVALID_NONTRANSITIONAL

Label has a character forbidden in non-transitional mode (TR46).

=head1 AUTHOR

Ben Davies <kaiepi@outlook.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Ben Davies

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
