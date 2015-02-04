BEGIN { push @*INC, <lib> }
use Modular;
use Test;

plan 5;

my $modulus = 7;

my $five = 5 Mod $modulus;
my $six = 6 Mod $modulus;

is $five + $six, 4, "simple modular addition";
is $five*$six, 2, "simple modular multiplication";

is (1 Mod $modulus)/$five, 3, "modular inverse";
is $six/$five, 4, "modular division";

$modulus = 9973;
my $r = (^$modulus).pick Mod $modulus;
is $r**10000, $r.Bridge.expmod( 10000, $modulus ), "modular exponentiation";

# vim: ft=perl6
