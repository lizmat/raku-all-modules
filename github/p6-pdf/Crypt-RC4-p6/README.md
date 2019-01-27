Crypt-RC4-p6
============

## SYNOPSIS

```
# Functional Style
  use Crypt::RC4;
  my $encrypted = RC4( $passphrase, $plaintext );
  my $decrypt = RC4( $passphrase, $encrypted );

# OO Style
  use Crypt::RC4;
  my Crypt::RC4 $ref = .new( $passphrase );
  my $encrypted = $ref.RC4( $plaintext );

  my Crypt::RC4 $ref2 = Crypt::RC4.new( $passphrase );
  my $decrypted = $ref2.RC4( $encrypted );

# process an entire file, one line at a time
# (Warning: Encrypted file leaks line lengths.)
  my Crypt::RC4 $ref3 .= new( $passphrase );
  for $fh.lines {
      chomp;
      say $ref3.RC4($_);
  }
```

## DESCRIPTION

A simple implementation of the RC4 algorithm, developed by RSA Security, Inc. Here is the description
from RSA's website:

RC4 is a stream cipher designed by Rivest for RSA Data Security (now RSA Security). It is a variable
key-size stream cipher with byte-oriented operations. The algorithm is based on the use of a random
permutation. Analysis shows that the period of the cipher is overwhelmingly likely to be greater than
10100. Eight to sixteen machine operations are required per output byte, and the cipher can be
expected to run very quickly in software. Independent analysts have scrutinized the algorithm and it
is considered secure.

Based substantially on the "RC4 in 3 lines of perl" found at http://www.cypherspace.org

A major bug in v1.0 was fixed by David Hook (dgh@wumpus.com.au).  Thanks, David.

## AUTHOR

- Kurt Kincaid (sifukurt@yahoo.com)
- Ronald Rivest for RSA Security, Inc.
- Ported from Perl 5 to 6 by David Warring 2015.

## BUGS

Disclaimer: Strictly speaking, this module uses the "alleged" RC4
algorithm. The Algorithm known as "RC4" is a trademark of RSA Security
Inc., and this document makes no claims one way or another that this
is the correct algorithm, and further, make no claims about the
quality of the source code nor any licensing requirements for
commercial use.

There's nothing preventing you from using this module in an insecure
way which leaks information. For example, encrypting multiple
messages with the same passphrase may allow an attacker to decode all of
them with little effort, even though they'll appear to be secured. If
serious crypto is your goal, be careful. Be very careful.

It's a pure-Perl implementation, so that rating of "Eight
to sixteen machine operations" is good for nothing but a good laugh.
If encryption and decryption are a bottleneck for you, please re-write
this module to use native code wherever practical.

## LICENSE

This is free software and may be modified and/or
redistributed under the same terms as Perl itself.

## SEE ALSO

- http://www.cypherspace.org
- http://www.rsasecurity.com
- http://www.achtung.com/crypto/rc4.html
- http://www.columbia.edu/~ariel/ssleay/rrc4.html
