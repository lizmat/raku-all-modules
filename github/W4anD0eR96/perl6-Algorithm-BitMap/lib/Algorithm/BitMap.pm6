use v6.c;

our class BitMap is export {
  has Int $!mask;
  has Int $!size;
  has Int $.bits;

  multi method new(:n($size)!) {
    my $mask = (1 +< $size) - 1;
    my $bits = 0;
    self.bless(:$size, :$mask, :$bits);
  }

  multi method new(:bits($bits)!) {
    my $size = $bits.base(2).chars;
    my $mask = (1 +< $size) - 1;
    self.bless(:$size, :$mask, :$bits);
  }

  multi method new() {
    self.bless(:size(0), :mask(0), :bits(0));
  }

  submethod BUILD(:$!size, :$!mask, :$!bits) { }

  multi method align(Int $n) {
    $!size = $n;
    $!mask = (1 +< $!size) - 1;
    self;
  }

  multi method set(Int $n) {
    $!bits +|= (1 +< $n);
    self;
  }

  multi method unset(Int $n) {
    $!bits +&= ((1 +< $n) +^ $!mask);
    self;
  }

  multi method fill() {
    $!bits = $!mask;
    self;
  }

  multi method clear() {
    $!bits = 0;
    self;
  }

  multi method get(Int $n) {
    ($!bits +> $n) +& 1;
  }

  multi method and(BitMap \other) {
    my $bits = (other.bits +& self.bits);
    BitMap.new(:$bits);
  }

  multi method or(BitMap \other) {
    my $bits = (other.bits +| self.bits);
    BitMap.new(:$bits);
  }

  multi method xor(BitMap \other) {
    my $bits = (other.bits +^ self.bits);
    BitMap.new(:$bits);
  }

  multi method neg() {
    BitMap.new(bits=>($!bits +^ $!mask));
  }

  multi method and-not(BitMap \other) {
    my $bits = (other.neg.bits +& self.bits);
    BitMap.new(:$bits);
  }

  multi method equals(BitMap \other) {
    other.bits == self.bits;
  }

  multi method count() {
    $!bits.base(2).match(/1/, :g).Int;
  }

  multi method Str() {
    $!bits.base(2);
  }

  multi method gist() {
    $!bits.base(2);
  }

  multi method debug() {
    say "mask: ", $!mask.base(2);
    say "length: ", $!size;
    say "bits: ", $!bits.base(2);
  }
}

multi sub infix:<+&>(BitMap \this, BitMap \other) is export {
  this.and(other);
}

multi sub infix:<+|>(BitMap \this, BitMap \other) is export {
  this.or(other);
}

multi sub infix:<+^>(BitMap \this, BitMap \other) is export {
  this.xor(other)
}

multi sub prefix:<+^>(BitMap \this) is export {
  this.neg;
}

multi sub infix:<+&^>(BitMap \this, BitMap \other) is export {
  this.and-not(other);
}

multi sub infix:<eq>(BitMap \this, BitMap \other) is export {
  this.equals(other);
}

=begin pod

=head1 NAME

Algorithm::BitMap - Efficient way to handle Boolean vector

=head1 SYNOPSIS

    use Algorithm::BitMap;

    my $bitmap1 = BitMap.new;
    my $bitmap2 = BitMap.new;

    say $bitmap1.set(4);
    say $bitmap2.fill;

    say $bitmap1 +| $bitmap2;
    say $bitmap1;

    say $bitmap1 +^= $bitmap2;
    say $bitmap1;

=head1 DESCRIPTION

Algorithm::BitMap is an efficient way to handle Boolean vector.

It is use an Int value C<$.bits> to simulate bool vector by its binary
representation.

Attention, when you get new BitMap by operating some previous BitMap, the new
one will be initialized using the least bits it needs. So the result of
C<(10000)_2 +^ (10010)_2 > is C<(10)_2>. To negate or fill the BitMap properly,
you can C<align> it at first.

=head2 CONSTRUCTOR

=head3 C<method new>

Defined as:

    multi method new()
    multi method new(:n!)
    multi method new(:bits!)

With no named parameters passed, it constructs a C<BitMap> initialized to be
all C<0>.

If you provide C<:n>, then the constructor builds a C<BitMap> having n bits.

If you provide C<:bits>, then the constructor build a C<BitMap> having
same C<bits>.

=head2 SUBROUTINE

=head3 C<method align>

Defined as:

    multi method align(Int $n)

Set size of the BitMap to be C<$n>.

=head3 C<method set>

Defined as:

    multi method set(Int $n)

Set the n-th bit of the BitMap, base on 0. It will modify the invocant.

=head3 C<method unset>

Defined as:

    multi method unset(Int $n)

Unset the n-th bit of the BitMap, base on 0. It will modify the invocant.

=head3 C<method fill>

Defined as:

    multi method fill()

Set all bits of the BitMap. It will modify the invocant.

=head3 C<method clear>

Defined as:

    multi method clear()

Unset all bits of the BitMap. It will modify the invocant.

=head3 C<method get>

Defined as:

    multi method get(Int $n)

Returns the n-th bits of the BitMap, base on 0.

=head3 C<method and>

Defined as:

    multi method and(BitMap \other)

Returns this BitMap bitwise AND the other BitMap.

=head3 C«sub infix:<+&>»

Defined as:

    multi sub infix:<+&>(BitMap \this, BitMap \other)

Same as C<this.and(other)>.

=head3 C<method or>

Defined as:

    multi method or(BitMap \other)

Returns this BitMap bitwise OR the other BitMap.

=head3 C«sub infix:<+|>»

Defined as:

    multi sub infix:<+|>(BitMap \this, BitMap \other)

Same as C<this.or(other)>.

=head3 C<method xor>

Defined as:

    multi method xor(BitMap \other)

Returns this BitMap bitwise XOR the other BitMap.

=head3 C«sub infix:<+^>»

Defined as:

    multi sub infix:<+^>(BitMap \this, BitMap \other)

Same as C<this.xor(other)>.

=head3 C<method neg>

Defined as:

    multi method neg()

Returns the BitMap bitwise negated.

=head3 C«sub prefix:<+^>»

Defined as:

    multi sub prefix:<+^>(BitMap \this)

Same as C<this.neg>.

=head3 C<method and-not>

Defined as:

    multi method and-not(BitMap \other)

Returns this BitMap bitwise AND-NOT the other BitMap.

=head3 C«sub infix:<+&^>»

Defined as:

    multi sub infix:<+&^>(BitMap \this, BitMap \other)

Same as C<this.and-not(other)>.

=head3 C<method equals>

Defined as:

    multi method equals(BitMap \other)

Returns whether this BitMap equals the other BitMap.

=head3 C«sub infix:<eq>»

Defined as:

    multi sub infix:<eq>(BitMap \this, BitMap \other)

Same as C<this.equals(other)>.

=head3 C<method count>

Defined as:

    multi method count()

Returns how many C<1>s the BitMap has.

=head3 C<method Str>

Defined as:

    multi method Str()

Returns binary representation of the BitMap.

=head1 AUTHOR

Alex Chen <wander4096@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Alex Chen

The Artistic License 2.0

=end pod
