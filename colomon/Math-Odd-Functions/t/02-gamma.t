use v6;
use Math::OddFunctions;
use Test;

plan 52;

sub postfix:<!>($n) { [*] 1..$n }

for 1..20 -> $n {
    is Γ($n), ($n - 1)!, "Γ($n) == {$n - 1}!";
}

for 1..20 -> $n {
    is_approx Γ($n.Num), ($n - 1)!, "Γ($n.Num) == {$n - 1}!";
}

is Γ(0), NaN, "Γ(0) is NaN";
is Γ(0.Num), NaN, "Γ(0.Num) is still NaN";
is_approx Γ(.5), 1.772453851, "Γ(.5) == 1.772453851";
is_approx Γ(-.5), -3.544907702, "Γ(-.5) == -3.544907702";
is_approx Γ(100), 9.332621544e+155, "Γ(100) == 9.332621544e+155";
is_approx Γ(100.Num), 9.332621544e+155, "Γ(100.Num) == 9.332621544e+155";

is logΓ(0), NaN, "logΓ(0) is NaN";
is_approx logΓ(.5), 0.5723649429, "logΓ(.5) == 0.5723649429";
is_approx logΓ(-.5), 1.265512123, "logΓ(-.5) == 1.265512123";
is_approx logΓ(1), 0, "logΓ(1) == 0";
is_approx logΓ(10), 12.80182748, "logΓ(10) == 12.80182748";
is_approx logΓ(100), 359.1342054, "logΓ(100) == 359.1342054";


