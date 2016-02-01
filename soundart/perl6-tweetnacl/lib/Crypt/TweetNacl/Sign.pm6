use v6;
use NativeCall;
use LibraryMake;
use Crypt::TweetNacl::Constants;

unit module Crypt::TweetNacl::Sign;

=begin pod
=head1 NAME

	   Crypt::TweetNacl::Sign - public key crypto library for signing

=head1 SYNOPSIS


=head1 DESCRIPTION

=head1 OPTIONS

=head1 RETURN VALUE

   In case problems arise this is reported by an exception.

=head1 ERRORS


=head1 DIAGNOSTICS


=head1 EXAMPLES


=head1 ENVIRONMENT


=head1 FILES


=head1 CAVEATS

   Various other(not documented) classes and methods might be exported
   by the library. Please ignore them.

=head1 BUGS


=head1 RESTRICTIONS


=head1 NOTES


=head1 SEE ALSO

   - https://nacl.cr.yp.to/sign.html
   - https://tweetnacl.cr.yp.to/tweetnacl-20131229.pdf

=head1 AUTHOR

    Frank Hartmann

=head1 HISTORY


=end pod



DOC INIT {
        use Pod::To::Text;
        pod2text($=pod);
}




#     unsigned char pk[crypto_sign_PUBLICKEYBYTES];
#     unsigned char sk[crypto_sign_SECRETKEYBYTES];

#     crypto_sign_keypair(pk,sk);

sub crypto_sign_keypair_int(CArray[int8], CArray[int8]) is symbol('crypto_sign_keypair') is native(TWEETNACL) returns int { * }

class KeyPair is export
{
    has $.secret;
    has $.public;
    submethod BUILD()
    {
        $!secret := CArray[int8].new;
        $!public := CArray[int8].new;
        $!secret[CRYPTO_SIGN_SECRETKEYBYTES - 1] = 0; # extend the array to 32 items
        $!public[CRYPTO_SIGN_PUBLICKEYBYTES - 1] = 0; # extend the array to 32 items
        my $ret = crypto_sign_keypair_int($!public,$!secret);
        if ($ret != 0) {
            die "crypto_box_keypair_int, bad return code: $ret";
        }
    }
}




# C NaCl also provides a crypto_sign function callable as follows:

#      #include "crypto_sign.h"

#      const unsigned char sk[crypto_sign_SECRETKEYBYTES];
#      const unsigned char m[...]; unsigned long long mlen;
#      unsigned char sm[...]; unsigned long long smlen;

#      crypto_sign(sm,&smlen,m,mlen,sk);

# The crypto_sign function signs a message m[0], ..., m[mlen-1] using
# the signer's secret key sk[0], sk[1], ...,
# sk[crypto_sign_SECRETKEYBYTES-1], puts the length of the signed
# message into smlen and puts the signed message into sm[0], sm[1],
# ..., sm[smlen-1]. It then returns 0.
# The maximum possible length smlen is mlen+crypto_sign_BYTES. The
# caller must allocate at least mlen+crypto_sign_BYTES bytes for sm.

#my $len = CArray[ulonglong].new; $len[0] = 0;
sub crypto_sign_int(CArray[int8], CArray[ulonglong], CArray[int8], ulonglong, CArray[int8]) is symbol('crypto_sign') is native(TWEETNACL) returns int { * }
sub crypto_sign_open_int(CArray[int8], CArray[ulonglong], CArray[int8], ulonglong, CArray[int8]) is symbol('crypto_sign_open') is native(TWEETNACL) returns int { * }


class CryptoSign is export
{
    has $.signature;
    submethod BUILD(Blob :$buf!, CArray[int8] :$sk!)
    {
        my $mlen = $buf.elems;
        $!signature = CArray[int8].new;
        my $msg = CArray[int8].new;
        my $tmp = CArray[int8].new;
        $tmp[CRYPTO_SIGN_BYTES + $mlen - 1] = 0;
        my $i;
        loop ($i=0; $i < $buf.elems; ++$i)
        {
            $msg[$i] = $buf[$i];
        }
        my $slen = CArray[ulonglong].new;
        $slen[0] = 0; # alloc
        my $ret = crypto_sign_int($tmp, $slen, $msg, $mlen, $sk);
        if ($ret != 0) {
            die "crypto_sign_int, bad return code: $ret";
        }
        $!signature[$slen[0] - 1] = 0;
        loop ($i=0; $i < $slen[0]; ++$i)
        {
             $!signature[$i] = $tmp[$i];
        }
    }
}


#  C NaCl also provides a crypto_sign_open function callable as follows:

#      #include "crypto_sign.h"

#      const unsigned char pk[crypto_sign_PUBLICKEYBYTES];
#      const unsigned char sm[...]; unsigned long long smlen;
#      unsigned char m[...]; unsigned long long mlen;

#      crypto_sign_open(m,&mlen,sm,smlen,pk);

# The crypto_sign_open function verifies the signature in sm[0], ...,
# sm[smlen-1] using the signer's public key pk[0], pk[1], ...,
# pk[crypto_sign_PUBLICKEYBYTES-1]. The crypto_sign_open function puts
# the length of the message into mlen and puts the message into m[0],
# m[1], ..., m[mlen-1]. It then returns 0.

# The maximum possible length mlen is smlen. The caller must allocate
# at least smlen bytes for m.

# If the signature fails verification, crypto_sign_open instead
# returns -1, possibly after modifying m[0], m[1], etc.


class CryptoSignOpen is export
{
    has $.message;
    submethod BUILD(CArray[int8] :$buf!, CArray[int8] :$pk!)
    {
        my $smlen = $buf.elems;
        my $imessage := Buf.new;
        my $tmp = CArray[int8].new;
        $tmp[$smlen - 1] = 0;
        my $i;
        my $mlen = CArray[ulonglong].new;
        $mlen[0] = 0; # alloc
        my $ret = crypto_sign_open_int($tmp, $mlen, $buf, $smlen, $pk);
        if ($ret != 0) {
            die "crypto_sign_int, bad return code: $ret";
        }
        my $xlen = $mlen[0];
        $imessage[$xlen - 1] = 0;
        loop ($i=0; $i < $xlen; ++$i)
        {
             $imessage[$i] = $tmp[$i];
        }
        $!message = $imessage;
    }
}
