use v6.c;
unit class Digest::BubbleBabble:ver<0.0.2>:auth<github:Kaiepi>;

class X::Digest::BubbleBabble::Decode is Exception {
    has Str $.error;
    method message(--> Str) {
        "Failed to decode fingerprint: $!error"
    }
}

constant VOWELS     = <a e i o u y>».ord;
constant CONSONANTS = <b c d f g h k l m n p r s t v z x>».ord;
constant ORD_X      = ord 'x';
constant ORD_HYPHEN = ord '-';
constant ORDER      = [VOWELS, CONSONANTS, VOWELS, CONSONANTS, [], CONSONANTS];

method encode(Blob $digest --> Blob) {
    my $len    = $digest.elems;
    my $seed   = 1;
    Blob.new: gather for 0,2,4...$len -> $i {
        FIRST take ORD_X;

        # We do this instead of using ^$len in the loop's range because this
        # allows empty buffers to get encoded properly.
        last if $i >= $len - 1;

        my Int $byte1 = $digest[$i];
        take VOWELS[(($byte1 +> 6 +& 3) + $seed) % 6];
        take CONSONANTS[$byte1 +> 2 +& 15];
        take VOWELS[(($byte1 +& 3) + $seed div 6) % 6];

        my Int $byte2 = $digest[$i + 1];
        take CONSONANTS[$byte2 +> 4 +& 15];
        take ORD_HYPHEN;
        take CONSONANTS[$byte2 +& 15];

        $seed = ($seed * 5 + $byte1 * 7 + $byte2) % 36;

        LAST {
            if $len %% 2 {
                take VOWELS[$seed % 6];
                take ORD_X;
                take VOWELS[$seed div 6];
                take ORD_X;
            } else {
                my Int $byte = $digest.tail;
                take VOWELS[(($byte +> 6 +& 3) + $seed) % 6];
                take CONSONANTS[$byte +> 2 +& 15];
                take VOWELS[(($byte +& 3) + $seed div 6) % 6];
                take ORD_X;
            }
        }
    }
}

method !decode-tuple(@tuple --> Seq) {
    gather for @tuple.kv -> $i, $byte {
        take ORDER[$i].first($byte, :k);
    }
};

method !decode-byte-double(@double, Int $pos --> Int) {
    my Int ($byte1, $byte2) = @double;

    X::Digest::BubbleBabble::Decode.new(
        error => "invalid byte at offset $pos"
    ).throw if $byte1 > 16;

    X::Digest::BubbleBabble::Decode.new(
        error => "invalid byte at offset {$pos + 2}"
    ).throw if $byte2 > 16;

    $byte1 +< 4 +| $byte2
}

method !decode-byte-triple(@triple, Int $seed, Int $pos --> Int) {
    my Int ($high, $mid, $low) = @triple;

    $high = ($high - ($seed % 6) + 6) % 6;
    X::Digest::BubbleBabble::Decode.new(
        error => "invalid byte at offset $pos"
    ).throw if $high >= 4;

    # Do nothing with $mid.
    X::Digest::BubbleBabble::Decode.new(
        error => "invalid byte at offset {$pos + 1}"
    ).throw if $mid > 16;

    $low = ($low - ($seed div 6 % 6) + 6) % 6;
    X::Digest::BubbleBabble::Decode.new(
        error => "invalid byte at offset {$pos + 2}"
    ).throw if $low >= 4;

    $high +< 6 +| $mid +< 2 +| $low;
}

method decode(Blob $fingerprint --> Blob) {
    X::Digest::BubbleBabble::Decode.new(
        error => "must start with x"
    ).throw if $fingerprint.head != ORD_X;
    X::Digest::BubbleBabble::Decode.new(
        error => "must end with x"
    ).throw if $fingerprint.tail != ORD_X;
    X::Digest::BubbleBabble::Decode.new(
        error => "invalid fingerprint length"
    ).throw if +$fingerprint % 6 != 5;

    my @tuples = $fingerprint[1..^*].rotor(6, :partial);
    my Int $seed = 1;
    Blob.new: gather for @tuples.kv -> $i, @tuple {
        my Int @bytes = self!decode-tuple(@tuple).grep(Int:D);
        last if +@bytes < 5;

        my Int $pos = $i * 6;
        take my Int $byte1 = self!decode-byte-triple(@bytes[0..2], $seed, $pos);
        take my Int $byte2 = self!decode-byte-double(@bytes[3..*], $pos);
        $seed = ($seed * 5 + $byte1 * 7 + $byte2) % 36;

        LAST {
            if @bytes.first(16, :k) eqv 1 {
                # Don't attempt to decode; these bytes don't contain any
                # information about the unencoded string.
                X::Digest::BubbleBabble::Decode.new(
                    error => "invalid byte at offset $pos"
                ).throw if @bytes.head != $seed % 6;
                X::Digest::BubbleBabble::Decode.new(
                    error => "invalid byte at offset $pos"
                ).throw if @bytes.tail != $seed div 6;
            } else {
                take self!decode-byte-triple(@bytes, $seed, $pos);
            }
        }
    }
}

method validate(Blob $fingerprint --> Bool) {
    return False if ($fingerprint.head != ORD_X);
    return False if ($fingerprint.tail != ORD_X);
    return False if (+$fingerprint % 6 != 5);

    my Int $seed   = 1;
    my     @tuples = $fingerprint[1..^*].rotor(6, :partial);
    for @tuples -> @tuple {
        my Int @bytes = self!decode-tuple(@tuple).grep(Int:D);
        if +@bytes >= 5 {
            my Int $high = (@bytes[0] - ($seed % 6) + 6) % 6;
            return False if $high >= 4;
            my Int $mid  = @bytes[1];
            return False if $mid > 16;
            my Int $low  = (@bytes[2] - ($seed div 6 % 6) + 6) % 6;
            return False if $low >= 4;

            my Int $upper = @bytes[3];
            return False if $upper > 16;
            my Int $lower = @bytes[4];
            return False if $lower > 16;

            my $byte1 = $high +< 6 +| $mid +< 2 +| $low;
            my $byte2 = $upper +< 4 +| $lower;
            $seed = ($seed * 5 + $byte1 * 7 + $byte2) % 36;
        } else {
            if @bytes[1] == 16 {
                return False if @bytes[0] != $seed % 6;
                return False if @bytes[2] != $seed div 6;
            } else {
                my $high = (@bytes[0] - ($seed % 6) + 6) % 6;
                return False if $high >= 4;
                my $mid  = @bytes[1];
                return False if $mid > 16;
                my $low  = (@bytes[2] - ($seed div 6 % 6) + 6) % 6;
                return False if $low >= 4;
            }
        }
    }

    True
}

=begin pod

=head1 NAME

Digest::BubbleBabble - Support for BubbleBabble string encoding and decoding

=head1 SYNOPSIS

  use Digest::BubbleBabble;

  my $digest = 'BubbleBabble is useful!'.encode;
  my $fingerprint = Digest::BubbleBabble.encode($digest);
  say $fingerprint.decode; # xidez-kidoh-sucen-furyd-sodyz-gidem-doled-cezof-rexux

  $digest = Digest::BubbleBabble.decode($fingerprint);
  say $digest.decode; # BubbleBabble is useful!

  say Digest::BubbleBabble.validate('xexax'.encode);        # True
  say Digest::BubbleBabble.validate('YXl5IGxtYW8K'.encode); # False

=head1 DESCRIPTION

Digest::BubbleBabble is a way of encoding digests in such a way that it can be
more easily legible and memorable for humans. This is useful for cryptographic
purposes.

=head1 METHODS

=item B<Digest::BubbleBabble.encode>(Blob I<$digest> --> Blob)

Returns the given digest blob, encoded as a BubbleBabble fingerprint.

=item B<Digest::BubbleBabble.decode>(Blob I<$fingerprint> --> Blob)

Returns the decoded BubbleBabble fingerprint blob. This throws an
C<X::Digest::BubbleBabble::Decode> exception if the fingerprint provided does
not follow BubbleBabble encoding.

=item B<Digest::BubbleBabble.validate>(Blob I<$fingerprint> --> Bool)

This validates whether or not a fingerprint uses valid BubbleBabble encoding.
Returns C<True> when the fingerprint is valid, and C<False> otherwise.

=head1 AUTHOR

Ben Davies (kaiepi)

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Ben Davies

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
