# Prime-Factor

NAME

Prime::Factor

SYNOPSIS

Exports the sub prime-factors();
Returns a list of all of the prime factors of a positive integer.

USAGE

    use Prime::Factor;

    say prime-factors(720); # (2 2 2 2 3 3 5)

    say prime-factors(2**100-1) # (3 5 5 5 11 31 41 101 251 601 1801 4051 8101 268501)


BUGS

Not very fast for very large integers. Or more accurately: not very fast for
integers that have two or more prime factors larger than ~2^40.

This would probably be better as a CORE function but until and if that arrives,
this is available.

AUTHOR

Stephen Schulze (often seen lurking on #perl6 IRC as thundergnat)

Adapted from code from Damian Conways "On the Shoulders of Giants"
presentation at YAPC::NA 2016 and Wikipedia "Pollard's rho algorithm".

LICENSE

Licensed under The Artistic 2.0; see LICENSE.
