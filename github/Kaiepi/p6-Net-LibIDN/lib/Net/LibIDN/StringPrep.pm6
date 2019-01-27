use v6.c;
use NativeCall;
use Net::LibIDN::Free;
use Net::LibIDN::Native;
unit class Net::LibIDN::StringPrep;

sub stringprep_check_version(Str --> Str) is native(LIB) { * }
method check_version(Str $version = '' --> Str) {
    stringprep_check_version($version) || ''
}

constant STRINGPREP_VERSION is export = stringprep_check_version('');

constant STRINGPREP_OK                       is export = 0;
constant STRINGPREP_CONTAINS_UNASSIGNED      is export = 1;
constant STRINGPREP_CONTAINS_PROHIBITED      is export = 2;
constant STRINGPREP_BIDI_BOTH_L_AND_RAL      is export = 3;
constant STRINGPREP_BIDI_LEADTRAIL_NOT_RAL   is export = 4;
constant STRINGPREP_BIDI_CONTAINS_PROHIBITED is export = 4;
constant STRINGPREP_TOO_SMALL_BUFFER         is export = 100;
constant STRINGPREP_PROFILE_ERROR            is export = 101;
constant STRINGPREP_FLAG_ERROR               is export = 102;
constant STRINGPREP_UNKNOWN_PROFILE          is export = 103;
constant STRINGPREP_ICONV_ERRO               is export = 104;
constant STRINGPREP_NFKC_FAILED              is export = 200;
constant STRINGPREP_MALLOC_ERROR             is export = 201;

constant STRINGPREP_NO_NFKC       is export = 1;
constant STRINGPREP_NO_BIDI       is export = 2;
constant STRINGPREP_NO_UNASSIGNED is export = 4;

sub stringprep_strerror(int32 --> Str) is native(LIB) { * }
method strerror(Int $code --> Str) { stringprep_strerror($code) || '' }

sub stringprep_profile(
    Str,
    Pointer[Str] is rw,
    Str,
    int32
    --> int32
) is native(LIB) { * }
proto method profile(Str, Str, Int $?, Int $? --> Str) { * }
multi method profile(Str $input, Str $profile, Int $flags = 0 --> Str) {
    my Pointer[Str] $outputptr .= new;
    my $code := stringprep_profile($input, $outputptr, $profile, $flags);
    return '' if $code != STRINGPREP_OK;

    my $output := $outputptr.deref;
    idn_free($outputptr);
    $output;
}
multi method profile(Str $input, Str $profile, Int $flags, Int $code is rw --> Str) {
    my Pointer[Str] $outputptr .= new;
    $code = stringprep_profile($input, $outputptr, $profile, $flags);
    return '' if $code != STRINGPREP_OK;

    my $output := $outputptr.deref;
    idn_free($outputptr);
    $output;
}

proto method nameprep(Str, Int $? --> Str) { * }
multi method nameprep(Str $input --> Str) {
    $.profile($input, 'Nameprep', 0)
}
multi method nameprep(Str $input, Int $code is rw --> Str) {
    $.profile($input, 'Nameprep', 0, $code)
}

proto method nameprep_no_unassigned(Str, Int $? --> Str) { * }
multi method nameprep_no_unassigned(Str $input --> Str) {
    $.profile($input, 'Nameprep', STRINGPREP_NO_UNASSIGNED)
}
multi method nameprep_no_unassigned(Str $input, Int $code is rw --> Str) {
    $.profile($input, 'Nameprep', STRINGPREP_NO_UNASSIGNED, $code)
}

proto method plain(Str, Int $? --> Str) { * }
multi method plain(Str $input --> Str) {
    $.profile($input, 'plain', 0)
}
multi method plain(Str $input, Int $code is rw --> Str) {
    $.profile($input, 'plain', 0, $code)
}

proto method kerberos5(Str, Int $? --> Str) { * }
multi method kerberos5(Str $input --> Str) {
    $.profile($input, 'KRBprep', 0)
}
multi method kerberos5(Str $input, Int $code is rw --> Str) {
    $.profile($input, 'KRBprep', 0, $code)
}

proto method xmpp_nodeprep(Str, Int $? --> Str) { * }
multi method xmpp_nodeprep(Str $input --> Str) {
    $.profile($input, 'Nodeprep', 0)
}
multi method xmpp_nodeprep(Str $input, Int $code is rw --> Str) {
    $.profile($input, 'Nodeprep', 0, $code)
}

proto method xmpp_resourceprep(Str, Int $? --> Str) { * }
multi method xmpp_resourceprep(Str $input --> Str) {
    $.profile($input, 'Resourceprep', 0)
}
multi method xmpp_resourceprep(Str $input, Int $code is rw --> Str) {
    $.profile($input, 'Resourceprep', 0, $code)
}

proto method iscsi(Str, Int $? --> Str) { * }
multi method iscsi(Str $input --> Str) {
    $.profile($input, 'ISCSIprep', 0)
}
multi method iscsi(Str $input, Int $code is rw --> Str) {
    $.profile($input, 'ISCSIprep', 0, $code)
}

#
# Utility methods for Net::LibIDN::Punycode
#

sub stringprep_utf8_to_ucs4(
    Blob[uint8],
    ssize_t,
    size_t is rw
    --> Pointer[uint32]
) is native(LIB) { * }
method utf8_to_ucs4(Blob[uint8] $input --> Blob[uint32]) {
    my ssize_t $len = $input.elems;
    my size_t $written;
    my $outputptr := stringprep_utf8_to_ucs4($input, $len, $written);
    return Blob[uint32].new if $written == 0;

    my Blob[uint32] $output .= new: ($outputptr[$_] for 0..^$written);
    idn_free($outputptr);
    $output;
}

sub stringprep_ucs4_to_utf8(
    Blob[uint32],
    ssize_t,
    size_t is rw,
    size_t is rw
    --> Pointer[uint8]
) is native(LIB) { * }
method ucs4_to_utf8(Blob[uint32] $input --> Blob[uint8]) {
    my ssize_t $len = $input.elems;
    my size_t $read;
    my size_t $written;
    my $outputptr := stringprep_ucs4_to_utf8($input, $len, $read, $written);
    return Blob[uint8].new if $written == 0;

    my Blob[uint8] $output .= new: ($outputptr[$_] for 0..^$written);
    idn_free($outputptr);
    $output;
}

=begin pod

=head1 NAME

Net::LibIDN::StringPrep

=head1 SYNOPSIS

    use Net::LibIDN::StringPrep;

    my $sp := Net::LibIN::StringPrep.new;
    say so $sp.check_version('0.4.0'); # True

    my $input := 'test';
    my Int $code;
    my $output := $sp.plain($input, $code);
    say "$output $code";     # test 0
    say $sp.strerror($code); # Success

=head1 DESCRIPTION

Net::LibIDN::StringPrep provides bindings for preparing Unicode strings as
input for various other functions. This can be used for protocol identifier
values, company and personal names, international domain names, etc.

=head1 METHODS

=item B<Net::LibIDN::StringPrep.check_version>(--> Str)
=item B<Net::LibIDN::StringPrep.check_version>(Str I<$version> --> Str)

Returns I<STRINGPREP_VERSION> if I<$version> is less than or equal to it,
otherwise returns an empty string.

=item B<Net::LibIDN::StringPrep.strerror>(Int I<$code> --> Str)

Returns I<$code> as a human readable error string.

=item B<Net::LibIDN::StringPrep.profile>(Str I<$input>, Str I<$profile>, Int I<$flags> = 0 --> Str)
=item B<Net::LibIDN::StringPrep.profile>(Str I<$input>, Str I<$profile>, Int I<$flags>, Int I<$code> is rw --> Str)

Prepares I<$input> according to I<$profile> and returns the result. I<$input>
must be encoded as UTF-8. If I<$code> is provided, it is assigned to
I<STRINGPREP_OK> if the function succeeded, or another error code if it fails.

=item B<Net::LibIDN::StringPrep.nameprep>(Str I<$input> --> Str)
=item B<Net::LibIDN::StringPrep.nameprep>(Str I<$input>, Int I<$code> is rw --> Str)

=item B<Net::LibIDN::StringPrep.nameprep_no_unassigned>(Str I<$input> --> Str)
=item B<Net::LibIDN::StringPrep.nameprep_no_unassigned>(Str I<$input>, Int I<$code> is rw --> Str)

=item B<Net::LibIDN::StringPrep.plain>(Str I<$input> --> Str)
=item B<Net::LibIDN::StringPrep.plain>(Str I<$input>, Int I<$code> is rw --> Str)

=item B<Net::LibIDN::StringPrep.kerberos5>(Str I<$input> --> Str)
=item B<Net::LibIDN::StringPrep.kerberos5>(Str I<$input>, Int I<$code> is rw --> Str)

=item B<Net::LibIDN::StringPrep.xmpp_nodeprep>(Str I<$input> --> Str)
=item B<Net::LibIDN::StringPrep.xmpp_nodeprep>(Str I<$input>, Int I<$code> is rw --> Str)

=item B<Net::LibIDN::StringPrep.xmpp_resourceprep>(Str I<$input> --> Str)
=item B<Net::LibIDN::StringPrep.xmpp_resourceprep>(Str I<$input>, Int I<$code> is rw --> Str)

=item B<Net::LibIDN::StringPrep.iscsi>(Str I<$input> --> Str)
=item B<Net::LibIDN::StringPrep.iscsi>(Str I<$input>, Int I<$code> is rw --> Str)

Prepares I<$input> with I<Net::LibIDN::StringPrep.profile> given the profiles
the methods are named after.

=head1 CONSTANTS

=item Str I<STRINGPREP_VERSION>

The version of LibIDN installed.

=head2 FLAGS

=item Int I<STRINGPREP_NO_NFKC>

Disables NFKC normalization and selects the non-NFKC case folding tables.

=item Int I<STRINGPREP_NO_BIDI>

Disables the BIDI step.

=item Int I<STRINGPREP_NO_UNASSIGNED>

Make the library return with an error if the given string contains unassigned
characters according to the profile.

=head2 ERRORS

=item Int I<STRINGPREP_OK>

Successful operation.

=item Int I<STRINGPREP_CONTAINS_UNASSIGNED>

String contains unassigned Unicode codepoints, which is forbidden by the
profile.

=item Int I<STRINGPREP_CONTAINS_PROHIBITED>

String contains codepoints prohibited by the profile.

=item Int I<STRINGPREP_BIDI_BOTH_L_AND_RAL>

String contains codepoints with conflicting bidirection categories.

=item Int I<STRINGPREP_BIDI_LEADTRAIL_NOT_RAL>

String's leading and trailing characters not of the proper bidirectional
category.

=item Int I<STRINGPREP_BIDI_CONTAINS_PROHIBITED>

String contains prohibited codepoints detected by bidirectional code.

=item Int I<STRINGPREP_TOO_SMALL_BUFFER>

Buffer handed to function was too small.

=item Int I<STRINGPREP_PROFILE_ERROR>

The stringprep profile was inconsistent. This usually indicates an internal
library error.

=item Int I<STRINGPREP_FLAG_ERROR>

The supplied flags conflicted with a profile.

=item Int I<STRINGPREP_UNKNOWN_PROFILE>

The supplied profile name was not known to the library.

=item Int I<STRINGPREP_ICONV_ERROR>

Failed to convert string in locale encoding.

=item Int I<STRINGPREP_NFKC_FAILED>

The Unicode NFKC operation failed. This usually indicates an internal library
error.

=item Int I<STRINGPREP_MALLOC_ERROR>

malloc() failed due to running out of memory.

=end pod
