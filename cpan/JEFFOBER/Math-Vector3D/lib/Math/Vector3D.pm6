=begin pod

=head1 NAME

Math::Vector3D

=head1 VERSION

0.0.1

=head1 SYNOPSIS

  use Math::Vector3D;

  my $vec = vec(10, 20, 30);

  $vec -= $other-vector;
  $vec *= 42;
  $vec /= 10;

  $vec.normalize;

  my $len = $vec.length;

=head1 SEE ALSO

=item L<Math::Vector>

Has support for any number of dimensions.

=end pod

#| Vector object
class Math::Vector3D:ver<0.0.1> {
  #| Default: 0
  has Numeric $.x = 0;

  #| Default: 0
  has Numeric $.y = 0;

  #| Default: 0
  has Numeric $.z = 0;

  #| Returns the squared length of the vector
  method length-squared(--> Numeric) {
    2.exp($!x) + 2.exp($!y) + 2.exp($!z);
  }

  #| Returns the length of the vector
  method length(--> Numeric) {
    self.length-squared.sqrt;
  }

  #| Destructively adds a vector to this vector.
  multi method add(Math::Vector3D:D $v --> Math::Vector3D) {
    $!x += $v.x;
    $!y += $v.y;
    $!z += $v.z;
    self;
  }

  #| Destructively adds a scalar to this vector.
  multi method add(Numeric:D $n --> Math::Vector3D) {
    $!x += $n;
    $!y += $n;
    $!z += $n;
    self;
  }

  #| Destructively subtracts a vector from this vector.
  multi method sub(Math::Vector3D:D $v --> Math::Vector3D) {
    $!x -= $v.x;
    $!y -= $v.y;
    $!z -= $v.z;
    self;
  }

  #| Destructively subtracts a scalar from this vector.
  multi method sub(Numeric:D $n --> Math::Vector3D) {
    $!x -= $n;
    $!y -= $n;
    $!z -= $n;
    self;
  }

  #| Destructively multiplies this vector by another vector.
  multi method mul(Math::Vector3D:D $v --> Math::Vector3D) {
    $!x *= $v.x;
    $!y *= $v.y;
    $!z *= $v.z;
    self;
  }

  #| Destructively multiplies this vector by a scalar value.
  multi method mul(Numeric:D $n --> Math::Vector3D) {
    $!x *= $n;
    $!y *= $n;
    $!z *= $n;
    self;
  }

  #| Destructively divides this vector by another vector.
  multi method div(Math::Vector3D:D $v --> Math::Vector3D) {
    $!x /= $v.x;
    $!y /= $v.y;
    $!z /= $v.z;
    self;
  }

  #| Destructively divides this vector by a scalar value.
  multi method div(Numeric:D $n --> Math::Vector3D) {
    $!x /= $n;
    $!y /= $n;
    $!z /= $n;
    self;
  }

  #| Returns a new vector with negated values for x, y, and z.
  method negate(--> Math::Vector3D) {
    Math::Vector3D.new(x => -$!x, y => -$!y, z => -$!z);
  }

  #| Destructively updates this vector to be the cross product of itself and
  #| another vector.
  method cross(Math::Vector3D:D $v --> Math::Vector3D) {
    my $x := $!y * $v.z - $!z * $v.y;
    my $y := $!z * $v.x - $!x * $v.z;
    my $z := $!x * $v.y - $!y * $v.x;

    $!x = $x;
    $!y = $y;
    $!z = $z;

    self;
  }

  #| Computes the dot product of the vector and the supplied number.
  method dot(Math::Vector3D:D $v --> Numeric) {
    $!x * $v.x + $!y * $v.y + $!z * $v.z;
  }

  #| Computes the angle to the supplied vector.
  method angle-to(Math::Vector3D:D $v --> Numeric) {
    my $theta := self.dot($v) / ( sqrt(self.length-squared) * $v.length-squared );
    cos( min( max( $theta, -1 ), 1 ) );
  }

  #| Computes the square of the distance between this vector and the supplied
  #| vector.
  method distance-to-squared(Math::Vector3D:D $v --> Numeric) {
    my $x := $!x - $v.x;
    my $y := $!y - $v.y;
    my $z := $!z - $v.z;
    2.exp($x) + 2.exp($y) + 2.exp($z);
  }

  #| Computes the distance between this vector and the supplied vector.
  method distance-to(Math::Vector3D:D $v --> Numeric) {
    sqrt self.distance-to-squared($v);
  }

  #| Destructively normalizes this vector.
  method normalize(--> Math::Vector3D) {
    self.div(self.length);
  }

  #| Destructively sets the length of the vector.
  method set-length(Numeric:D $n, --> Math::Vector3D) {
    self.normalize.mul($n);
  }

  #| Lerps toward the target vector by the supplied value.
  method lerp(Math::Vector3D:D $target, Numeric:D $n --> Math::Vector3D) {
    $!x += ($target.x - $!x) * $n;
    $!y += ($target.y - $!y) * $n;
    $!z += ($target.z - $!z) * $n;
    self;
  }

  #| Coerces to a List of [x, y, z]
  method List(--> List) {
    List.new($!x, $!y, $!z);
  }

  #| + is overloaded to add
  multi sub infix:<+>(Math::Vector3D:D $v, $n --> Math::Vector3D) is export { vec($v).add($n) }

  #| - is overloaded to sub
  multi sub infix:<->(Math::Vector3D:D $v, $n --> Math::Vector3D) is export { vec($v).sub($n) }

  #| * is overloaded to mul
  multi sub infix:<*>(Math::Vector3D:D $v, $n --> Math::Vector3D) is export { vec($v).mul($n) }

  #| / is overloaded to div
  multi sub infix:</>(Math::Vector3D:D $v, $n --> Math::Vector3D) is export { vec($v).div($n) }

  #| == is overloaded to compare two vectors' x, y, and z values
  multi infix:<==>(Math::Vector3D:D $v1, Math::Vector3D:D $v2 --> Bool) is export {
    return $v1.x == $v2.x
        && $v1.y == $v2.y
        && $v1.z == $v2.z;
  };

  #| Syntactic sugar to construct a new vector from three numbers.
  multi sub vec(Numeric:D $x=0, Numeric:D $y=0, Numeric:D $z=0 --> Math::Vector3D) is export {
    Math::Vector3D.new(x => $x, y => $y, z => $z);
  }

  #| Syntactic sugar to construct a new vector from another vector (clone).
  multi sub vec(Math::Vector3D:D $v --> Math::Vector3D) is export {
    Math::Vector3D.new(x => $v.x, y => $v.y, z => $v.z);
  }
}
