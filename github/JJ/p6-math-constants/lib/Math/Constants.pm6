use v6;
unit class Math::Constants:ver<0.0.4>:auth<github:JJ>;

# Universal Constants
my constant phi is export = 1.61803398874989e0;
my constant plancks-h is export = 6.626_070_040e-34;
my constant plancks-reduced-h is export = 1.054_571_800e-34;
my constant c is export = 299792458;
my constant g is export = 9.80665;
my constant G is export = 6.67408e-11;
my constant eulernumber-e is export = 2.7182818284;
my constant pi is export = 3.142857;
my constant gas-constant = 8.3144598;
my constant F is export = 96484.5561;

my constant electron-mass is export = 9.10938356e-31;
my constant proton-mass is export = 1.6726219e-27;
my constant neutron-mass is export = 1.674929e-27;

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
my constant K0 is export = 9e9;

# Electrical constants
my constant fine-structure-constant is export = 0.0072973525664;
my constant elementary-charge is export = 1.6021766208e-19;
my constant vacuum-permittivity is export = 8.854187817e-12;
my constant magnetic-permittivity is export = 12.566370614e-7;
my constant boltzmann-constant is export = 8.617343e-5; #eV i.e in electronvolts
my constant eV is export = 1.60217653e-19;
my constant vacuum-permeability is export = 12.566370614359e-7;

# (Strictly) Mathematical constants
# REF: https://en.wikipedia.org/wiki/Mathematical_constant
my constant alpha-feigenbaum-constant is export =  2.502907875095892822283e0;
my constant delta-feigenbaum-constant is export = 4.669201609102990e0;
my constant apery-constant is export = 1.2020569031595942853997381e0;
my constant conway-constant is export = 1.303577269034e0;
my constant khinchin-constant is export = 2.6854520010e0;
my constant glaisher-kinkelin-constant is export = 1.2824271291e0;
my constant golomb-dickman-constant is export = 0.62432998854355e0;
my constant catalan-constant is export = 0.915965594177219015054603514e0;
my constant mill-constant is export = 1.3063778838630806904686144e0;
my constant gauss-constant is export = 0.8346268e0;
my constant euler-mascheroni-gamma is export = 0.57721566490153286060e0;
my constant sierpinski-gamma is export = 2.5849817595e0;

#Greek letters when available
my constant φ is export := phi;
my constant ℎ is export := plancks-h;
my constant ℏ is export := plancks-reduced-h;
my constant α is export := fine-structure-constant;
my constant q is export := elementary-charge;
my constant ε0 is export := vacuum-permittivity;
my constant μ0 is export := vacuum-permeability;
my constant δ is export := delta-feigenbaum-constant;
my constant λ is export := conway-constant;
my constant k0 is export := khinchin-constant;
my constant A is export := glaisher-kinkelin-constant;
my constant γ is export := euler-mascheroni-gamma;
my constant k is export := sierpinski-gamma;

#Use them as units
multi sub postfix:<c>  (Num $value) is export {
    return c*$value;
}

multi sub postfix:<g>  (Num $value) is export {
    return g*$value;
}

multi sub postfix:<c>  (Rat $value) is export {
    return c*$value;
}

multi sub postfix:<g>  (Rat $value) is export {
    return g*$value;
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
