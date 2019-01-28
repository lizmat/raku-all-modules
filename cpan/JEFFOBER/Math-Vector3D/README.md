NAME
====

Math::Vector3D

VERSION
=======

0.0.1

SYNOPSIS
========

    use Math::Vector3D;

    my $vec = vec(10, 20, 30);

    $vec -= $other-vector;
    $vec *= 42;
    $vec /= 10;

    $vec.normalize;

    my $len = $vec.length;

SEE ALSO
========

  * [Math::Vector](Math::Vector)

Has support for any number of dimensions.

class Math::Vector3D
--------------------

Vector object

### has Numeric $.x

Default: 0

### has Numeric $.y

Default: 0

### has Numeric $.z

Default: 0

### method length-squared

```perl6
method length-squared() returns Numeric
```

Returns the squared length of the vector

### method length

```perl6
method length() returns Numeric
```

Returns the length of the vector

### multi method add

```perl6
multi method add(
    Math::Vector3D:D $v
) returns Math::Vector3D
```

Destructively adds a vector to this vector.

### multi method add

```perl6
multi method add(
    Numeric:D $n
) returns Math::Vector3D
```

Destructively adds a scalar to this vector.

### multi method sub

```perl6
multi method sub(
    Math::Vector3D:D $v
) returns Math::Vector3D
```

Destructively subtracts a vector from this vector.

### multi method sub

```perl6
multi method sub(
    Numeric:D $n
) returns Math::Vector3D
```

Destructively subtracts a scalar from this vector.

### multi method mul

```perl6
multi method mul(
    Math::Vector3D:D $v
) returns Math::Vector3D
```

Destructively multiplies this vector by another vector.

### multi method mul

```perl6
multi method mul(
    Numeric:D $n
) returns Math::Vector3D
```

Destructively multiplies this vector by a scalar value.

### multi method div

```perl6
multi method div(
    Math::Vector3D:D $v
) returns Math::Vector3D
```

Destructively divides this vector by another vector.

### multi method div

```perl6
multi method div(
    Numeric:D $n
) returns Math::Vector3D
```

Destructively divides this vector by a scalar value.

### method negate

```perl6
method negate() returns Math::Vector3D
```

Returns a new vector with negated values for x, y, and z.

### method cross

```perl6
method cross(
    Math::Vector3D:D $v
) returns Math::Vector3D
```

Destructively updates this vector to be the cross product of itself and another vector.

### method dot

```perl6
method dot(
    Math::Vector3D:D $v
) returns Numeric
```

Computes the dot product of the vector and the supplied number.

### method angle-to

```perl6
method angle-to(
    Math::Vector3D:D $v
) returns Numeric
```

Computes the angle to the supplied vector.

### method distance-to-squared

```perl6
method distance-to-squared(
    Math::Vector3D:D $v
) returns Numeric
```

Computes the square of the distance between this vector and the supplied vector.

### method distance-to

```perl6
method distance-to(
    Math::Vector3D:D $v
) returns Numeric
```

Computes the distance between this vector and the supplied vector.

### method normalize

```perl6
method normalize() returns Math::Vector3D
```

Destructively normalizes this vector.

### method set-length

```perl6
method set-length(
    Numeric:D $n
) returns Math::Vector3D
```

Destructively sets the length of the vector.

### method lerp

```perl6
method lerp(
    Math::Vector3D:D $target,
    Numeric:D $n
) returns Math::Vector3D
```

Lerps toward the target vector by the supplied value.

### method List

```perl6
method List() returns List
```

Coerces to a List of [x, y, z]

### multi sub infix:<+>

```perl6
multi sub infix:<+>(
    Math::Vector3D:D $v,
    $n
) returns Math::Vector3D
```

+ is overloaded to add

### multi sub infix:<->

```perl6
multi sub infix:<->(
    Math::Vector3D:D $v,
    $n
) returns Math::Vector3D
```

- is overloaded to sub

### multi sub infix:<*>

```perl6
multi sub infix:<*>(
    Math::Vector3D:D $v,
    $n
) returns Math::Vector3D
```

* is overloaded to mul

### multi sub infix:</>

```perl6
multi sub infix:</>(
    Math::Vector3D:D $v,
    $n
) returns Math::Vector3D
```

/ is overloaded to div

### multi sub infix:<==>

```perl6
multi sub infix:<==>(
    Math::Vector3D:D $v1,
    Math::Vector3D:D $v2
) returns Bool
```

== is overloaded to compare two vectors' x, y, and z values

### multi sub vec

```perl6
multi sub vec(
    Numeric:D $x = 0,
    Numeric:D $y = 0,
    Numeric:D $z = 0
) returns Math::Vector3D
```

Syntactic sugar to construct a new vector from three numbers.

### multi sub vec

```perl6
multi sub vec(
    Math::Vector3D:D $v
) returns Math::Vector3D
```

Syntactic sugar to construct a new vector from another vector (clone).

