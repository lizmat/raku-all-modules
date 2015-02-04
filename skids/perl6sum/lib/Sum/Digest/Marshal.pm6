
use Sum;

=NAME Sum::Digest::Marshal - process string addends for Digest::* work-alikes.

=begin DESCRIPTION
    This module marshals Str values the same way the existing PIR-based
    Digest modules do, so that a Sum:: role may be mixed in to emulate
    those modules.
=end DESCRIPTION

=begin pod

=head2 role Sum::Digest::Marshal [ :$encoding?, :$blocksize = 64 ]

    Concatinates lists or arrays of Str, and then builds buffers of
    $blocksize bytes (the last block may be shorter) from the lower byte
    of the ordinal of each character.

    The PIR-based routines decimate the upper bytes of wide characters,
    and will produce the same checksum for e.g. "fo⍅o" and "foEo".

    If you would like a version that encodes to UTF8 before calculating
    the checksum, pass C<:encoding<utf8>>.  This is the only value
    accepted for this parameter.

=end pod

role Sum::Digest::Marshal [ :$blocksize = 64 ] {

  multi method push (*@addends --> Failure) {
    my $accum = blob8.new();
    for @addends -> $a {
      my $pos = 0;

      while ($a.chars > $pos) {
        my $take = min($blocksize - $accum.bytes, $a.chars - $pos);
	my $took = $a.substr($pos, $take);
        $accum = blob8.new($accum[ ], $took.ords);
	last unless $accum.bytes == $blocksize;
	self.add($accum);
	$accum = blob8.new();
	$pos += $take;
      }
    }
    self.add($accum);
    my $res = Failure.new(X::Sum::Push::Usage.new());
    $res.defined;
    $res;
  }
}

role Sum::Digest::Marshal [ :$encoding where "utf8", :$blocksize = 64 ] {
  method push (*@addends --> Failure) {
    my $accum = blob8.new();
    for @addends {
      my $utf = $_.encode;
      my $pos = 0;

      while ($utf.bytes > $pos) {
        my $take = min($blocksize - $accum.bytes, $utf.bytes - $pos);
	my $took = $utf.subbuf($pos, $take);
        if ($accum.bytes) {
          $accum = blob8.new($accum[ ], $took[ ]);
        }
        else {
	  $accum = $took;
        }
	last unless $accum.bytes == $blocksize;
	self.add($accum);
	$accum = blob8.new();
	$pos += $take;
      }
    }
    self.add($accum);
    my $res = Failure.new(X::Sum::Push::Usage.new());
    $res.defined;
    $res;
  }
}


