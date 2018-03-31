use v6.c;
use NativeCall;
use Net::LibIDN::Free;
use Net::LibIDN::Native;
use Net::LibIDN::StringPrep;
unit class Net::LibIDN::Punycode;

constant PUNYCODE_SUCCESS    is export = 0;
constant PUNYCODE_BAD_INPUT  is export = 1;
constant PUNYCODE_BIG_OUTPUT is export = 2;
constant PUNYCODE_OVERFLOW   is export = 3;

sub punycode_encode(
    size_t,
    Blob[uint32],
    Pointer[uint8],
    size_t is rw,
    Blob[uint8] is rw
    --> int32
) is native(LIB) { * }
proto method encode(Str, Int $? --> Str) { * }
multi method encode(Str $domain --> Str) {
    my $input := Net::LibIDN::StringPrep.utf8_to_ucs4($domain.encode('utf8-c8'));
    my size_t $inputlen = $input.elems;
    my $case_flags := Pointer[uint8].new;
    my size_t $outputlen = 4096;
    my Blob[uint8] $output .= allocate: $outputlen;
    my $code := punycode_encode($inputlen, $input, $case_flags, $outputlen, $output);
    return '' if $code != PUNYCODE_SUCCESS;

    $output.subbuf(0, $outputlen).decode('utf8-c8');
}
multi method encode(Str $domain, Int $code is rw --> Str) {
    my $input := Net::LibIDN::StringPrep.utf8_to_ucs4($domain.encode('utf8-c8'));
    my size_t $inputlen = $input.elems;
    my $case_flags := Pointer[uint8].new;
    my size_t $outputlen = 4096;
    my Blob[uint8] $output .= allocate: $outputlen;
    $code = punycode_encode($inputlen, $input, $case_flags, $outputlen, $output);
    return '' if $code != PUNYCODE_SUCCESS;

    $output.subbuf(0, $outputlen).decode('utf8-c8');
}

sub punycode_decode(
    size_t,
    Blob[uint8],
    size_t is rw,
    Blob[uint32] is rw,
    Pointer[uint8]
    --> int32
) is native(LIB) { * }
proto method decode(Str, Int $? --> Str) { * }
multi method decode(Str $domain --> Str) {
    my $input := $domain.encode('utf8-c8');
    my size_t $inputlen = $input.elems;
    my size_t $outputlen = 4096;
    my Blob[uint32] $output .= allocate: $outputlen;
    my $case_flags := Pointer[uint8].new;
    my $code := punycode_decode($inputlen, $input, $outputlen, $output, $case_flags);
    return '' if $code != PUNYCODE_SUCCESS;

    Net::LibIDN::StringPrep
        .ucs4_to_utf8($output.subbuf(0, $outputlen))
        .decode('utf8-c8');
}
multi method decode(Str $domain, Int $code is rw --> Str) {
    my $input := $domain.encode('utf8-c8');
    my size_t $inputlen = $input.elems;
    my size_t $outputlen = 4096;
    my Blob[uint32] $output .= allocate: $outputlen;
    my $case_flags := Pointer[uint8].new;
    $code = punycode_decode($inputlen, $input, $outputlen, $output, $case_flags);
    return '' if $code != PUNYCODE_SUCCESS;

    Net::LibIDN::StringPrep
        .ucs4_to_utf8($output.subbuf(0, $outputlen))
        .decode('utf8-c8');
}

=begin pod

=head1 NAME

Net::LibIDN::Punycode

=head1 SYNOPSIS

    use Net::LibIDN::Punycode;

    my $punycode := Net::LibIDN::Punycode.new;
    my $domain = "m\xFC\xDFli.de";
    my Int $code;
    my $ace := $punycode.encode($domain, $code);
    say "$ace $code"; # ml.de-bta5u 0
    $domain = $punycode.decode($ace, $code);
    say "$domain $code"; # müßli.de 0

=head1 DESCRIPTION

Net::LibIDN::Punycode provides bindings for encoding Unicode strings as ACE
encoded Punycode.

=head1 METHODS

=item B<Net::LibIDN::Punycode.encode>(Str I<$input> --> Str)
=item B<Net::LibIDN::Punycode.encode>(Str I<$input>, Int I<$code> is rw --> Str)

Encodes a UTF-8 string I<$input> as Punycode. If I<$code> is provided, it is
assigned to I<PUNYCODE_SUCCESS> on success, or another error code on fail.

=item B<Net::LibIDN::Punycode.decode>(Str I<$input> --> Str)
=item B<Net::LibIDN::Punycode.decode>(Str I<$input>, Int I<$code> is rw --> Str)

Decodes a Punycode string I<$input> as UTF-8. If I<$code> is provided, it is
assigned to I<PUNYCODE_SUCCESS> on success, or another error code on fail.

=head1 CONSTANTS

=head2 ERRORS

=item Int B<PUNYCODE_SUCCESS>

Successful operation.

=item Int B<PUNYCODE_BAD_INPUT>

Input is invalid.

=item Int B<PUNYCODE_BIG_OUTPUT>

Output would exceed the space provided.

=item Int B<PUNYCODE_OVERFLOW>

Input needs wider integers to process.

=end pod
