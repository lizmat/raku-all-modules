use v6;
use NativeCall;
use Crypt::TweetNacl::Constants;

unit module Crypt::TweetNacl::Basics;


sub remove_leading_elems($return_type!, $buf!, Int $num_elems) is export
{
    my $data := $return_type.new;
    my $dlen = $buf.elems - $num_elems;
    $data[$dlen - 1] = 0;
    my $i = 0;
    loop ($i = 0; $i < $dlen; $i++)
    {
        $data[$i] = $buf[$i + $num_elems];
    }
    return $data;
}

# int crypto_hash(u8 *out,const u8 *m,u64 n)
sub crypto_hash(CArray[uint8], CArray[uint8], ulonglong) is symbol('crypto_hash')
    is native(TWEETNACL) is export returns int { * }

class CryptoHash is export {
    has $!buf;
    has $.bytes;
    submethod BUILD(:$!buf) {
        my $tmp = CArray[uint8].new;
        $tmp[CRYPTO_HASH_BYTES - 1] = 0;
        my $mlen = $!buf.elems;
        my $msg = CArray[uint8].new($mlen);
        $msg[$_] = $!buf[$_] for 0..$mlen-1;
        crypto_hash($tmp,$msg,$mlen);
        $!bytes = Buf.new($tmp);
    }
    method hex {
        return $!bytes.map({.fmt('%02x')}).join;
    }
}

# void randombytes(unsigned char *x,unsigned long long xlen)

# todo check signedness of xlen
sub randombytes_int(CArray[int8], ulonglong) is symbol('randombytes') is native(TWEETNACL) is export { * }

sub randombytes(int $xlen!) is export
{
    my $data = CArray[int8].new;
    $data[$xlen - 1] = 0;
    randombytes_int($data, $xlen);
    return $data;
}

sub nonce() is export
{
    return randombytes(CRYPTO_BOX_NONCEBYTES);
}

sub prepend_zeros($buf!, Int $num_zeros!) is export
{
    my $mlen = $num_zeros + $buf.elems;
    my $msg  = CArray[int8].new;
    $msg[$mlen - 1] = 0;        #alloc
    my Int $i;
    loop ($i=0; $i < $num_zeros ; $i++)
    {
        $msg[$i] = 0;
    }
    loop ($i=0; $i < $buf.elems; ++$i)
    {
        $msg[$i+$num_zeros] = $buf[$i];
    }
    return $msg;
}

class Ciphertext is export
{
    has $.data;
    has $.nonce;
    has $!dlen;

    submethod BUILD(CArray :$zdata!, CArray :$nonce!)
    {
        $!data = remove_leading_elems(CArray[int8], $zdata, CRYPTO_BOX_BOXZEROBYTES);
        $!dlen = $!data.elems;
        $!nonce = $nonce;
    }

    # return data with prepend zeros
    method zdata()
    {
        my $zdata = prepend_zeros($!data, CRYPTO_BOX_BOXZEROBYTES);
        return $zdata;

    }
}
