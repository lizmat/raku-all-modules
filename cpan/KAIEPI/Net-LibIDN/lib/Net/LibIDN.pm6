use v6.c;
use NativeCall;
use Net::LibIDN::Free;
use Net::LibIDN::Native;
unit class Net::LibIDN:ver<0.0.2>:auth<github:Kaiepi>;

constant IDNA_ACE_PREFIX is export = 'xn--';

constant IDNA_ALLOW_UNASSIGNED     is export = 0x0001;
constant IDNA_USE_STD3_ASCII_RULES is export = 0x0002;

constant IDNA_SUCCESS                is export = 0;
constant IDNA_STRINGPREP_ERROR       is export = 1;
constant IDNA_PUNYCODE_ERROR         is export = 2;
constant IDNA_CONTAINS_NON_LDH       is export = 3;
constant IDNA_CONTAINS_MINUS         is export = 4;
constant IDNA_INVALID_LENGTH         is export = 5;
constant IDNA_NO_ACE_PREFIX          is export = 6;
constant IDNA_ROUNDTRIP_VERIFY_ERROR is export = 7;
constant IDNA_CONTAINS_ACE_PREFIX    is export = 8;
constant IDNA_ICONV_ERROR            is export = 9;
constant IDNA_MALLOC_ERROR           is export = 201;
constant IDNA_DLOPEN_ERROR           is export = 202;

sub idna_to_ascii_8z(Str, Pointer[Str] is rw, int32 --> int32) is native(LIB) { * }
proto method to_ascii_8z(Str, Int $?, Int $? --> Str) { * }
multi method to_ascii_8z(Str $input, Int $flags = 0 --> Str) {
    my Pointer[Str] $outputptr .= new;
    my $code := idna_to_ascii_8z($input, $outputptr, $flags);
    return '' if $code != IDNA_SUCCESS;

    my $output := $outputptr.deref;
    idn_free($outputptr);
    $output;
}
multi method to_ascii_8z(Str $input, Int $flags, Int $code is rw --> Str) {
    my Pointer[Str] $outputptr .= new;
    $code = idna_to_ascii_8z($input, $outputptr, $flags);
    return '' if $code != IDNA_SUCCESS;

    my $output := $outputptr.deref;
    idn_free($outputptr);
    $output;
}

sub idna_to_unicode_8z8z(Str, Pointer[Str] is rw, int32 --> int32) is native(LIB) { * }
proto method to_unicode_8z8z(Str, Int $?, Int $? --> Str) { * }
multi method to_unicode_8z8z(Str $input, Int $flags = 0 --> Str) {
    my Pointer[Str] $outputptr .= new;
    my $code := idna_to_unicode_8z8z($input, $outputptr, $flags);
    return '' if $code != IDNA_SUCCESS;

    my $output := $outputptr.deref;
    idn_free($outputptr);
    $output;
}
multi method to_unicode_8z8z(Str $input, Int $flags, Int $code is rw --> Str) {
    my Pointer[Str] $outputptr .= new;
    $code = idna_to_unicode_8z8z($input, $outputptr, $flags);
    return '' if $code != IDNA_SUCCESS;

    my $output := $outputptr.deref;
    idn_free($outputptr);
    $output;
}

=begin pod

=head1 NAME

Net::LibIDN - Perl 6 bindings for GNU LibIDN

=head1 SYNOPSIS

    use Net::LibIDN;

    my $idna := Net::LibIDN.new;

    my $domain := "m\xFC\xDFli.de";
    my Int $code;
    my $ace := $idna.to_ascii_8z($domain, 0, $code);
    say "$ace $code"; # xn--mssli-kva.de 0

    my $domain2 := $idna.to_unicode_8z8z($domain, 0, $code);
    say "$domain2 $code"; # müssli.de 0

=head1 DESCRIPTION

Net::LibIDN is a wrapper for the GNU LibIDN library. It provides bindings for
its IDNA, Punycode, stringprep, and TLD functions. See Net::LibIDN::Punycode,
Net::LibIDN::StringPrep, and Net::LibIDN::TLD for more documentation.

=head1 METHODS

=item B<Net::LibIDN.to_ascii_8z>(Str I<$input> --> Str)
=item B<Net::LibIDN.to_ascii_8z>(Str I<$input>, Int I<$flags> --> Str)
=item B<Net::LibIDN.to_ascii_8z>(Str I<$input>, Int I<$flags>, Int I<$code> is rw --> Str)

Converts a UTF8 encoded string I<$input> to ASCII and returns the output.
I<$code>, if provided, is assigned to I<IDNA_SUCCESS> on success, or another
error code otherwise.

=item B<Net::LibIDN.to_unicode_8z8z>(Str I<$input> --> Str)
=item B<Net::LibIDN.to_unicode_8z8z>(Str I<$input>, Int I<$flags> --> Str)
=item B<Net::LibIDN.to_unicode_8z8z>(Str I<$input>, Int I<$flags>, Int I<$code> is rw --> Str)

Converts an ACE encoded domain name I<$input> to UTF8 and returns the output.
I<$code>, if provided, is assigned to I<IDNA_SUCCESS> on success, or another
error code otherwise.

=head1 CONSTANTS

=item Int B<IDNA_ACE_PREFIX>

String containing the official IDNA prefix, "xn--".

=head2 FLAGS

=item Int B<IDNA_ALLOW_UNASSIGNED>

Allow unassigned Unicode codepoints.

=item Int B<IDNA_USE_STD3_ASCII_RULES>

Check output to ensure it is a STD3 conforming hostname.

=head2 ERRORS

=item Int B<IDNA_SUCCESS>

Successful operation.

=item Int B<IDNA_STRINGPREP_ERROR>

Error during string preparation.

=item Int B<IDNA_PUNYCODE_ERROR>

Error during punycode operation.

=item Int B<IDNA_CONTAINS_NON_LDH>

I<IDNA_USE_STD3_ASCII_RULES> flag was passed, but the given string contained
non-LDH ASCII characters.

=item Int B<IDNA_CONTAINS_MINUS>

I<IDNA_USE_STD3_ASCII_RULES> flag was passed, but the given string contained a
leading or trailing hyphen-minus (u002D).

=item Int B<IDNA_INVALID_LENGTH>

The final output string is not within the range of 1 to 63 characters.

=item Int B<IDNA_NO_ACE_PREFIX>

The string does not begin with I<IDNA_ACE_PREFIX> (for ToUnicode).

=item Int B<IDNA_ROUNDTRIP_VERIFY_ERROR>

The ToASCII operation on the output string does not equal the input.

=item Int B<IDNA_CONTAINS_ACE_PREFIX>

The input string begins with I<IDNA_ACE_PREFIX> (for ToASCII).

=item Int B<IDNA_ICONV_ERROR>

Could not convert string to locale encoding.

=item Int B<IDNA_MALLOC_ERROR>

Could not allocate buffer (this is typically a fatal error).

=item Int B<IDNA_DLOPEN_ERROR>

Could not dlopen the libcidn DSO (only used internally in LibC).

=head1 AUTHOR

Ben Davies <kaiepi@outlook.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Ben Davies

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
