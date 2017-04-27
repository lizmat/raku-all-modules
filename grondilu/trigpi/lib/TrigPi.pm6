unit module TrigPi;

sub sinPi(Real $x --> Real) is export {
    $x < 0   ?? -sinPi(-$x) !!
    $x < 1/4 ??  sin(pi*$x) !!
    $x ≤ 1/2 ??  cos(pi*(1/2 - $x)) !!
    $x < 1   ??  sinPi(1 - $x) !!
    $x < 2   ?? -sinPi($x - 1) !!
    sinPi($x % 2)
}

sub cosPi(Real $x --> Real) is export {
    $x < 0   ??  cosPi(-$x) !!
    $x < 1/4 ??  cos(pi*$x) !!
    $x ≤ 1/2 ??  sin(pi*(1/2 - $x)) !!
    $x < 1   ?? -cosPi(1 - $x) !!
    $x < 2   ?? -cosPi($x - 1) !!
    cosPi($x % 2)
}

sub cisPi(Real $x --> Complex)  is export { cosPi($x) + i*sinPi($x) }

