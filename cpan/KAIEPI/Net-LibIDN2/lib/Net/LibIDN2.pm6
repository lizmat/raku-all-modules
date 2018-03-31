use v6.c;
use NativeCall;
unit class Net::LibIDN2:ver<0.0.3>:auth<github:Kaiepi>;

constant LIB = 'idn2';

sub idn2_check_version(Str --> Str) is native(LIB) { * }
method check_version(Str $version = '' --> Str) { idn2_check_version($version) || '' }

constant IDN2_VERSION        is export = idn2_check_version('');
constant IDN2_VERSION_NUMBER is export = {
    my $digits := IDN2_VERSION.comb(/\d+/).map({ :16($_) });
    given +$digits {
        when 2 { :16(sprintf '%02x%02x0000', $digits) }
        when 3 { :16(sprintf '%02x%02x%04x', $digits) }
    }
}();
constant IDN2_VERSION_MAJOR  is export = IDN2_VERSION_NUMBER +& 0xFF000000 +> 24;
constant IDN2_VERSION_MINOR  is export = IDN2_VERSION_NUMBER +& 0x00FF0000 +> 16;
constant IDN2_VERSION_PATCH  is export = IDN2_VERSION_NUMBER +& 0x0000FFFF;

constant IDN2_LABEL_MAX_LENGTH  is export = 63;
constant IDN2_DOMAIN_MAX_LENGTH is export = 255;

constant IDN2_NFC_INPUT            is export = 0x0001;
constant IDN2_ALABEL_ROUNDTRIP     is export = 0x0002;
constant IDN2_TRANSITIONAL         is export = 0x0004;
constant IDN2_NONTRANSITIONAL      is export = 0x0008;
constant IDN2_ALLOW_UNASSIGNED     is export = 0x0010;
constant IDN2_USE_STD3_ASCII_RULES is export = 0x0020;

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

sub idn2_strerror(int32 --> Str) is native(LIB) { * }
method strerror(Int $code --> Str) { idn2_strerror($code) || '' }

sub idn2_strerror_name(int32 --> Str) is native(LIB) { * }
method strerror_name(Int $code --> Str) { idn2_strerror_name($code) || '' }

sub idn2_to_ascii_8z(Str, Pointer[Str] is rw, int32 --> int32) is native(LIB) { * }
proto method to_ascii_8z(Str, Int $?, Int $? --> Str) { * }
multi method to_ascii_8z(Str $input, Int $flags = 0 --> Str) {
    my Pointer[Str] $outputptr .= new;
    my $code := idn2_to_ascii_8z($input, $outputptr, $flags);
    return '' if $code != IDN2_OK;

    my $output := $outputptr.deref;
    idn2_free($outputptr);
    $output;
}
multi method to_ascii_8z(Str $input, Int $flags, Int $code is rw --> Str) {
    my Pointer[Str] $outputptr .= new;
    $code = idn2_to_ascii_8z($input, $outputptr, $flags);
    return '' if $code != IDN2_OK;

    my $output := $outputptr.deref;
    idn2_free($outputptr);
    $output;
}

sub idn2_to_unicode_8z8z(Str, Pointer[Str] is rw, int32 --> int32) is native(LIB) { * }
proto method to_unicode_8z8z(Str, Int $?, Int $? --> Str) { * }
multi method to_unicode_8z8z(Str $input, Int $flags = 0 --> Str) {
    my Pointer[Str] $outputptr .= new;
    my $code := idn2_to_unicode_8z8z($input ~ "\x00", $outputptr, $flags);
    return '' if $code != IDN2_OK;

    my $output := $outputptr.deref;
    idn2_free($outputptr);
    $output;
}
multi method to_unicode_8z8z(Str $input, Int $flags, Int $code is rw --> Str) {
    my Pointer[Str] $outputptr .= new;
    $code = idn2_to_unicode_8z8z($input, $outputptr, $flags);
    return '' if $code != IDN2_OK;

    my $output := $outputptr.deref;
    idn2_free($outputptr);
    $output;
}

sub idn2_lookup_u8(Str, Pointer[Str] is rw, int32 --> int32) is native(LIB) { * }
proto method lookup_u8(Str, Int $?, Int $? --> Str) { * }
multi method lookup_u8(Str $input, Int $flags = 0 --> Str) {
    my Pointer[Str] $outputptr .= new;
    my $code := idn2_lookup_u8($input, $outputptr, $flags);
    return '' if $code != IDN2_OK;

    my $output := $outputptr.deref;
    idn2_free($outputptr);
    $output;
}
multi method lookup_u8(Str $input, Int $flags, Int $code is rw --> Str) {
    my Pointer[Str] $outputptr .= new;
    $code = idn2_lookup_u8($input, $outputptr, $flags);
    return '' if $code != IDN2_OK;

    my $output := $outputptr.deref;
    idn2_free($outputptr);
    $output;
}

sub idn2_register_u8(Str, Str, Pointer[Str] is rw, int32 --> int32) is native(LIB) { * }
proto method register_u8(Str, Str $?, Int $?, Int $? --> Str) { * }
multi method register_u8(Str $uinput, Str $ainput, Int $flags = 0 --> Str) {
    my Pointer[Str] $outputptr .= new;
    my $code := idn2_register_u8($uinput, $ainput, $outputptr, $flags);
    return '' if $code != IDN2_OK;

    my $output := $outputptr.deref;
    idn2_free($outputptr);
    $output;
}
multi method register_u8(Str $uinput, Str $ainput, Int $flags, Int $code is rw --> Str) {
    my Pointer[Str] $outputptr .= new;
    $code = idn2_register_u8($uinput, $ainput, $outputptr, $flags);
    return '' if $code != IDN2_OK;

    my $output := $outputptr.deref;
    idn2_free($outputptr);
    $output;
}

=begin pod

=head1 NAME

Net::LibIDN2 - Perl 6 bindings for GNU LibIDN2

=head1 SYNOPSIS

=begin code

    use Net::LibIDN2;

    my $idn := Net::LibIDN2.new;

    my Int $code;
    my $ulabel := "m\xFC\xDFli";
    my $alabel := $idn.lookup_u8($ulabel, IDN2_NFC_INPUT, $code);
    say "$alabel $code"; # xn--mli-5ka8l 0

    my $result := $idn.register_u8($ulabel, $alabel, IDN2_NFC_INPUT, $code);
    say "$result $code"; # xn--mli-5ka8l 0
    say $idn.strerror($code);      # success
    say $idn.strerror_name($code); # IDN2_OK

=end code

=head1 DESCRIPTION

Net::LibIDN2 is a Perl 6 wrapper for the GNU LibIDN2 library.

=head1 METHODS

=item B<Net::LibIDN2.check_version>(--> Str)
=item B<Net::LibIDN2.check_version>(Str I<$version> --> Str)

Compares I<$version> against the version of LibIDN2 installed and returns either
an empty string if I<$version> is greater than the version installed, or
I<IDN2_VERSION> otherwise.

=item B<Net::LibIDN2.strerror>(Int I<$errno> --> Str)

Returns the error represented by I<$errno> in human readable form.

=item B<Net::LibIDN2.strerror_name>(Int I<$errno> --> Str)

Returns the internal error name of I<$errno>.

=item B<Net::LibIDN2.to_ascii_8z>(Str I<$input> --> Str)
=item B<Net::LibIDN2.to_ascii_8z>(Str I<$input>, Int I<$flags> --> Str)
=item B<Net::LibIDN2.to_ascii_8z>(Str I<$input>, Int I<$flags>, Int I<$code> is rw --> Str)

Converts a UTF8 encoded string I<$input> to ASCII and returns the output.
I<$code>, if provided, is assigned to I<IDN2_OK> on success, or another
error code otherwise. Requires LibIDN2 v2.0.0 or greater.

=item B<Net::LibIDN2.to_unicode_8z8z>(Str I<$input> --> Str)
=item B<Net::LibIDN2.to_unicode_8z8z>(Str I<$input>, Int I<$flags> --> Str)
=item B<Net::LibIDN2.to_unicode_8z8z>(Str I<$input>, Int I<$flags>, Int I<$code> is rw --> Str)

Converts an ACE encoded domain name I<$input> to UTF8 and returns the output.
I<$code>, if provided, is assigned to I<IDN2_OK> on success, or another
error code otherwise. Requires LibIDN v2.0.0 or greater.

=item B<Net::LibIDN2.lookup_u8>(Str I<$input> --> Str)
=item B<Net::LibIDN2.lookup_u8>(Str I<$input>, Int I<$flags> --> Str)
=item B<Net::LibIDN2.lookup_u8>(Str I<$input>, Int I<$flags>, Int I<$code> is rw --> Str)

Performs an IDNA2008 lookup string conversion on I<$input>. See RFC 5891, section
5. I<$input> must be a UTF8 encoded string in NFC form if no I<IDN2_NFC_INPUT> flag
is passed.


=item B<Net::LibIDN2.register_u8>(Str I<$uinput>, Str I<$ainput> --> Str)
=item B<Net::LibIDN2.register_u8>(Str I<$uinput>, Str I<$ainput>, Int I<$flags> --> Str)
=item B<Net::LibIDN2.register_u8>(Str I<$uinput>, Str I<$ainput>, Int I<$flags>, Int I<$code> is rw --> Str)

Performs an IDNA2008 register string conversion on I<$uinput> and I<$ainput>. See RFC
5891, section 4. I<$uinput> must be a UTF8 encoded string in NFC form if no
I<IDN2_NFC_INPUT> flag is passed. I<$ainput> must be an ACE encoded string.

=head1 CONSTANTS

=item Int B<IDN2_LABEL_MAX_LENGTH>

The maximum label length.

=item Int B<IDN2_DOMAIN_MAX_LENGTH>

The maximum domain name length.

=head2 VERSIONING

=item Str B<IDN2_VERSION>

The version of LibIDN2 installed.

=item Int B<IDN2_VERSION_NUMBER>

The version of LibIDN2 installed represented as a 32 bit integer. The first
pair of bits represents the major version, the second represents the minor
version, and the last 4 represent the patch version.

=item Int B<IDN2_VERSION_MAJOR>

The major version of LibIDN2 installed.

=item Int B<IDN2_VERSION_MINOR>

The minor version of LidIDN2 installed.

=item Int B<IDN2_VERSION_PATCH>

The patch version of LibIDN2 installed.

=head2 FLAGS

=item Int B<IDN2_NFC_INPUT>

Normalize the input string using the NFC format.

=item Int B<IDN2_ALABEL_ROUNDTRIP>

Perform optional IDNA2008 lookup roundtrip check.

=item Int B<IDN2_TRANSITIONAL>

Perform Unicode TR46 transitional processing.

=item Int B<IDN2_NONTRANSITIONAL>

Perform Unicode TR46 non-transitional processing.

=head2 ERRORS

=item Int B<IDN2_OK>

Success.

=item Int B<IDN2_MALLOC>

Memory allocation failure.

=item Int B<IDN2_NO_CODESET>

Failed to determine a string's encoding.

=item Int B<IDN2_ICONV_FAIL>

Failed to transcode a string to UTF8.

=item Int B<IDN2_ENCODING_ERROR>

Unicode data encoding error.

=item Int B<IDN2_NFC>

Failed to normalize a string.

=item Int B<IDN2_PUNYCODE_BAD_INPUT>

Invalid input to Punycode.

=item Int B<IDN2_PUNYCODE_BIG_OUTPUT>

Punycode output buffer is too small.

=item Int B<IDN2_PUNYCODE_OVERFLOW>

Punycode conversion would overflow.

=item Int B<IDN2_TOO_BIG_DOMAIN>

Domain is larger than I<IDN2_DOMAIN_MAX_LENGTH>.

=item Int B<IDN2_TOO_BIG_LABEL>

Label is larger than I<IDN2_LABEL_MAX_LENGTH>.

=item Int B<IDN2_INVALID_ALABEL>

Invalid A-label.

=item Int B<IDN2_UALABEL_MISMATCH>

Given U-label and A-label do not match.

=item Int B<IDN2_INVALID_FLAGS>

Invalid combination of flags.

=item Int B<IDN2_NOT_NFC>

String is not normalized in NFC format.

=item Int B<IDN2_2HYPHEN>

String has forbidden two hyphens.

=item Int B<IDN2_HYPHEN_STARTEND>

String has forbidden start/end hyphen.

=item Int B<IDN2_LEADING_COMBINING>

String has forbidden leading combining character.

=item Int B<IDN2_DISALLOWED>

String has disallowed character.

=item Int B<IDN2_CONTEXTJ>

String has forbidden context-j character.

=item Int B<IDN2_CONTEXTJ_NO_RULE>

String has context-j character without any rull.

=item Int B<IDN2_CONTEXTO>

String has forbidden context-o character.

=item Int B<IDN2_CONTEXTO_NO_RULE>

String has context-o character without any rull.

=item Int B<IDN2_UNASSIGNED>

String has forbidden unassigned character.

=item Int B<IDN2_BIDI>

String has forbidden bi-directional properties.

=item Int B<IDN2_DOT_IN_LABEL>

Label has forbidden dot (TR46).

=item Int B<IDN2_INVALID_TRANSITIONAL>

Label has a character forbidden in transitional mode (TR46).

=item Int B<IDN2_INVALID_NONTRANSITIONAL>

Label has a character forbidden in non-transitional mode (TR46).

=head1 AUTHOR

Ben Davies <kaiepi@outlook.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Ben Davies

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
