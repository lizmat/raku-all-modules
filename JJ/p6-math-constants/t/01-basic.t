use v6;
use Test;
use lib ('../lib','lib');
use Math::Constants;

my @constants-names = <G phi plancks-h plancks-reduced-h elementary-charge vacuum-permittivity>;
my @constants;
@constants-names ==> map  { EVAL $_  }  ==> @constants;

@constants.map( { is .WHAT, (Num), "Type OK"} ); 

is c.WHAT, (Int), "c is OK";
is α.WHAT, (Rat), "e is OK";

is-approx ℎ/(2*π), ℏ, "Planck's constants";
is-approx φ, (1 + sqrt(5))/2, "Golden ratio";
is-approx α, 0.00729735256, "Fine structure";
is-approx e²/(4*π*ε0*ℏ*c), α, "Fine structure constant";

is-approx 0.1c, c/10, "Speed of light as unit";

done-testing;
