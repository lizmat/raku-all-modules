use v6;
use Test;
use lib ('../lib','lib');
use Math::Constants;

my @constants-names = <G phi plancks-h plancks-reduced-h elementary-charge vacuum-permittivity alpha-feigenbaum-constant delta-feigenbaum-constant apery-constant conway-constant khinchin-constant glaisher-kinkelin-constant golomb-dickman-constant catalan-constant mill-constant gauss-constant euler-mascheroni-gamma sierpinski-gamma electron-mass proton-mass neutron-mass>;
my @constants;
@constants-names ==> map  { EVAL $_  }  ==> @constants;

@constants.map( { is .WHAT, (Num), "Type OK"} );

is c.WHAT, (Int), "c is OK";
is g.WHAT, (Rat), "g is OK";
is α.WHAT, (Rat), "e is OK";

is-approx ℎ/(2*π), ℏ, "Planck's constants";
is-approx φ, (1 + sqrt(5))/2, "Golden ratio";
is-approx α, 0.00729735256, "Fine structure";
is-approx q²/(4*π*ε0*ℏ*c), α, "Fine structure constant";
is-approx L, 6.022140857e23, "Avogadro's number";

is-approx 0.1c, c/10, "Speed of light as unit";

is-approx 0.1g, g/10, "Standard gravity";


done-testing;
