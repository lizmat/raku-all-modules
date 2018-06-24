use v6;
unit module Sustenance::Types;

subset SomeStr of Str is export where *.so;
constant FoodName is export = SomeStr;
constant ServingSize is export = SomeStr;

subset Natural of Rat is export where * >= 0;
constant Calories is export = Natural;
constant Protein is export = Natural;
constant Carbohydrates is export = Natural;
constant Fat is export = Natural;

subset Positive of Rat is export where * > 0;
constant Servings is export = Positive;

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
