#--------------------------------------------------------------------#
# Crypt::RC4
#       Date Written:   07-Jun-2000 04:15:55 PM
#       Last Modified:  13-Dec-2001 03:33:49 PM 
#       Author:         Kurt Kincaid (sifukurt@yahoo.com)
#       Copyright (c) 2001, Kurt Kincaid
#           All Rights Reserved.
#       Perl 6 Port:    08-Nov-2015 05:24:25 PM by
#                       david.warring@gmail.com
#
#       This is free software and may be modified and/or
#       redistributed under the same terms as Perl itself.
#--------------------------------------------------------------------#

class Crypt::RC4:ver<0.0.2> {

    has uint8 @!state;
    has uint8 $!x;
    has uint8 $!y;

    multi submethod BUILD(Blob :$key!) {
        @!state = setup( $key );
        $!x = 0;
        $!y = 0;
    }

    multi submethod BUILD(:$key!) is default {
        self.BUILD( :key(Blob.new: $key) )
    }

    multi method RC4(@buf is copy --> Array) {
        for @buf {
	    my $sx := @!state[++$!x];
	    $!y += $sx;
	    my $sy := @!state[$!y];
	    ($sx, $sy) = ($sy, $sx);
	    my uint8 $mod-sum = $sx + $sy;
	    $_ +^= @!state[$mod-sum];
        }
        @buf;
    }

    multi method RC4(Blob $message --> Blob) is default {
	my uint8 @buf = $message.list;
	Blob.new: self.RC4( @buf );
    }

   sub setup( $key --> array[uint8] ) {
	my uint8 @state = 0..255;
	my uint8 $y = 0;
	for 0..255 -> uint8 $x {
	    $y += $key[$x % +$key] + @state[$x];
	    (@state[$x], @state[$y]) = (@state[$y], @state[$x]);
	}
	@state;
    }

    our sub RC4($key, |c) is export(:DEFAULT) {
	$?CLASS.new( :$key ).RC4( |c );
    }

}

=begin pod

=head1 NAME

Crypt::RC4 - Perl implementation of the RC4 encryption algorithm

=head1 SYNOPSIS

# Functional Style
  use Crypt::RC4;
  my $encrypted = RC4( $passphrase, $plaintext );
  my $decrypt = RC4( $passphrase, $encrypted );
  
# OO Style
  use Crypt::RC4;
  my $ref = Crypt::RC4.new( :key($passphrase) );
  my $encrypted = $ref.RC4( $plaintext );

  my $ref2 = Crypt::RC4.new( $passphrase );
  my $decrypted = $ref2.RC4( $encrypted );

# process an entire file, one line at a time
# (Warning: Encrypted file leaks line lengths.)
  my $ref3 = Crypt::RC4.new( :key($passphrase) );
  for $fh.lines {
      chomp;
      say $ref3.RC4($_);
  }

=head1 DESCRIPTION

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

=head1 AUTHOR

Kurt Kincaid (sifukurt@yahoo.com)
Ronald Rivest for RSA Security, Inc.

=head1 BUGS

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

=head1 LICENSE

This is free software and may be modified and/or
redistributed under the same terms as Perl itself.

=head1 SEE ALSO

L<perl>, L<http://www.cypherspace.org>, L<http://www.rsasecurity.com>, 
L<http://www.achtung.com/crypto/rc4.html>, 
L<http://www.columbia.edu/~ariel/ssleay/rrc4.html>

=cut

=end pod
