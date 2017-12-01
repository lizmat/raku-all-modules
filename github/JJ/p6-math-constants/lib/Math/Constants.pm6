use v6;
unit class Math::Constants;

# Universal Constants
my constant phi is export = 1.61803398874989e0;
my constant plancks-h is export = 6.626_070_040e-34;
my constant plancks-reduced-h is export = 1.054_571_800e-34;
my constant c is export = 299792458;
my constant G is export = 6.67408e-11;
my constant eulernumber-e is export = 2.7182818284;
my constant pi is export = 3.142857;
my constant gas-constant = 8.3144598;
my constant F is export = 96484.5561;


# REF: http://www.ebyte.it/library/educards/constants/ConstantsOfPhysicsAndMath.html
my constant quantum-ratio is export = 2.417989348e14;
my constant planck-mass is export = 2.17651e-8;
my constant mp is export := planck-mass;
my constant planck-time is export = 5.39106e-44;
my constant tp is export := planck-time;
my constant planck-length is export = 1.616199e-35;
my constant lp is export := planck-length;
my constant planck-temperature is export = 1.416833e+32;
my constant L is export = 6.022140857e23;

# Electrical constants
my constant fine-structure-constant is export = 0.0072973525664;
my constant elementary-charge is export = 1.6021766208e-19;
my constant vacuum-permittivity is export = 8.854187817e-12;
my constant boltzmann-constant is export = 8.617343e-5; #eV i.e in electronvolts
my constant eV is export = 1.60217653e-19;
my constant vacuum-permeability is export = 12.566370614359e-7;

#Greek letters when available
my constant φ is export := phi;
my constant ℎ is export := plancks-h;
my constant ℏ is export := plancks-reduced-h;
my constant α is export := fine-structure-constant;
my constant q is export := elementary-charge;
my constant ε0 is export := vacuum-permittivity;
my constant μ0 is export := vacuum-permeability;

#Use them as units
multi sub postfix:<c>  (Num $value) is export {
    return c*$value;
}

multi sub postfix:<c>  (Rat $value) is export {
    return c*$value;
}

=begin pod

=head1 NAME

Math::Constants - A few Math and Physics constants using original notation

=head1 SYNOPSIS

  use Math::Constants;

say "We have ", phi, " ", plancks-h, " ",  plancks-reduced-h, " ", c
, " ", G, " “,eulernumber-e ,” “,pi ,” and ", fine-structure-constant, " plus ",
elementary-charge, " ", vacuum-permittivity ,” “, boltzmann-constant ,” and “,eV ,” ;
say "And also  φ ", φ, " α ", α,  " ℎ ",  ℎ, " and ℏ ", ℏ,
" with q ", q, " and ε0 ", ε0;

   say "We are flying at speed ", .1c;

=head1 DESCRIPTION

Math::Constants is a set of constants used in Physics, Chemistry and Math.

φ is a mathematical constant called the Golden Ratio, ℎ,
and ℏ are different versions of Planck's constant,
c is the speed of light, G the universal gravitation constant,
and α the fine structure constant.

    There are a set of 3 electrical constants: the elementary charge q,
the vacuum permittivity ε₀ and the fine structure constant α

    C<c> can also be used as an unit of speed,
as in .001c for a thousandth of the speed of light.

This set is by no means complete,
but they are just a few examples that you can use in your programs.

=head1 AUTHOR

JJ Merelo <jjmerelo@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2016, 2017 JJ Merelo

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
