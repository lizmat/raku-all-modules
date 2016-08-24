use v6.c;

use Digest::HMAC;
use OpenSSL::Digest;

#-------------------------------------------------------------------------------
unit package PKCS5;

constant C-HLENS = {

  md5           => 16,

  sha1          => 20,
#  sha224        => 28,
  sha256        => 32,
#  sha384        => 48,
#  sha512        => 64,
};

#-------------------------------------------------------------------------------
# RFC2898
#
# Options:        CGH        underlying cryptographic hash function
#                 hlen       length in octets of pseudorandom function output
#
# Input:          P          password, an octet string
#                 S          salt, an eight-octet string
#                 c          iteration count, a positive integer
#                 dkLen      intended length in octets of derived key,
#                            a positive integer, at most (2^32 - 1) * hLen
#
# Output:         DK         derived key, a dkLen-octet string
#
class PBKDF2 {

  has Callable $!CGH;
  has Int $!dklen where $_ > 0;
  has Int $!l where $_ > 0;
  has Int $!r;
  has Int $!hlen;

  #-----------------------------------------------------------------------------
  submethod BUILD (
    Callable :$CGH = &sha1,     # underlying cryptographic hash function
    Int :$dklen,                # intended length in octets of derived key,
  ) {

#say &$CGH.perl;

    # Check prf name and get its output length if known
    &$CGH.perl ~~ m/ ['sub'|'method'] \s+ ( <.ident>+ ) /;
    my $prf-name = $/[0].Str;
    if C-HLENS{$prf-name}:exists {
      $!hlen = C-HLENS{$prf-name};
      $!CGH = $CGH;
    }

    else {
      die 'Not a known pseudorandom function';
    }

    # Check requested derivation length
    if $dklen.defined {
      die 'Wrong derive key length' if $dklen > (2**32 - 1) * $!hlen;
      $!dklen = $dklen;
    }

    # When dklen not defined, take output length of the pseudorandom function
    else {
      $!dklen = $!hlen;
    }

    $!l = ceiling($!dklen / $!hlen);
    $!r = $!dklen - ($!l - 1) * $!hlen;
  }

  #-----------------------------------------------------------------------------
  method derive ( Buf $pw, Buf $salt, Int $i --> Buf ) {

    my Buf $T .= new;
    for 1 .. $!l -> $lc {
      my Buf $Ti = self!F( $pw, $salt, $i, $lc);
      $T ~= $Ti;
    }

    $T.subbuf( 0, $!dklen);
  }

  #-----------------------------------------------------------------------------
  method derive-hex ( Buf $pw, Buf $salt, Int $i --> Str ) {

    my Buf $T .= new;
    for 1 .. $!l -> $lc {
#say "lc: $lc";
      my Buf $Ti = self!F( $pw, $salt, $i, $lc);
      $T ~= $Ti;
    }

    $T.subbuf( 0, $!dklen).>>.fmt('%02x').join;
  }

  #-----------------------------------------------------------------------------
  method !F ( Buf $pw, Buf $salt, Int $i, Int $lc --> Buf ) {

    my Buf @U = [];

    @U[0] = hmac( $pw, $salt ~ self!encode-int32-BE($lc), &$!CGH);
    my $F = @U[0];
    for 1 ..^ $i -> $ci {
#say "i: $ci" unless $ci % 500;
      @U[$ci] = hmac( $pw, @U[$ci - 1], &$!CGH);
      for ^($F.elems) -> $ei {
        $F[$ei] = $F[$ei] +^ @U[$ci][$ei];
      }
    }

    Buf.new($F);
  }

  #-----------------------------------------------------------------------------
  method !encode-int32-BE ( Int:D $i --> Buf ) {
    my int $ni = $i;
    Buf.new((
      $ni +& 0xFF, ($ni +> 0x08) +& 0xFF,
      ($ni +> 0x10) +& 0xFF, ($ni +> 0x18) +& 0xFF
    ).reverse);
  }
}
