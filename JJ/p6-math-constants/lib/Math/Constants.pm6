use v6;
unit class Math::Constants;

my constant phi is export = 1.61803398874989e0;
my constant plancks-h is export = 6.626_070_040e-34;
my constant plancks-reduced-h is export = 1.054_571_800e-34;
my constant c is export = 299792458;
my constant G is export = 6.67408e-11;

#Electrical constants
my constant fine-structure-constant is export = 0.0072973525664;
my constant elementary-charge is export = 1.6021766208e-19;
my constant vacuum-permittivity is export = 8.854187817e-12;

#Greek letters when available
my constant φ is export := phi;
my constant ℎ is export := plancks-h;
my constant ℏ is export := plancks-reduced-h;
my constant α is export := fine-structure-constant;
my constant e is export := elementary-charge;
my constant ε0 is export := vacuum-permittivity;

#Use them as units
multi sub postfix:<c>  (Num $value) is export {
    return c*$value;
}

multi sub postfix:<c>  (Rat $value) is export {
    return c*$value;
}

=begin pod

=head1 NAME

Math::Constants - blah blah blah

=head1 SYNOPSIS

  use Math::Constants;

say "We have ", phi, " ", plancks-h, " ",  plancks-reduced-h, " ", c
, " ", G, " and ", fine-structure-constant, " plus ",
elementary-charge, " and ", vacuum-permittivity ;
say "And also  φ ", φ, " α ", α,  " ℎ ",  ℎ, " and ℏ ", ℏ,
" with e ", e, " and ε0 ", ε0;

   say "We are flying at speed ", .1c;

=head1 DESCRIPTION

Math::Constants is a set of constants used in Physics and Math.

φ is a mathematical constant called the Golden Ratio, ℎ,
and ℏ are different versions of Planck's constant,
c is the speed of light, G the universal gravitation constant,
and α the fine structure constant.

    There are a set of 3 electrical constants: the elementary charge e,
the vacuum permittivity ε₀ and the fine structure constant α

    C<c> can also be used as an unit of speed,
as in .001c for a thousandth of the speed of light.
   
This set is by no means complete,
but they are just a few examples that you can use in your programs. 

=head1 AUTHOR

JJ Merelo <jjmerelo@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 JJ Merelo

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
