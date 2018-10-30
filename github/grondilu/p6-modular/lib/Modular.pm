class Modulo does Real {
    has ($.residue, $.modulus);
    multi method new($n, :$modulus) { self.new: :residue($n % $modulus), :$modulus }
    method Bridge { $.residue }
    multi method gist { "$.residue 「mod $.modulus」" }
    method succ { self.new: $.residue.succ, :$.modulus }
    multi method Inverse {
        return Modulo unless $.residue gcd $.modulus == 1;
        my ($c, $d, $uc, $vc, $ud, $vd) = ($.residue, $.modulus, 1, 0, 0, 1);
        my $q;
        while $c != 0 {
            ($q, $c, $d) = ($d div $c, $d % $c, $c);
            ($uc, $vc, $ud, $vd) = ($ud - $q*$uc, $vd - $q*$vc, $uc, $vc);
        }
        return self.new: $ud < 0 ?? $ud + $.modulus !! $ud, :$.modulus;
    }
}

sub infix:<Mod>(Int $n, Int $modulus where * > 1)
is export returns Modulo { Modulo.new: $n, :$modulus }

multi infix:<+>(Modulo $a, Int $b) { $a + ($b Mod $a.modulus) }
multi infix:<+>(Int $a, Modulo $b) { ($a Mod $b.modulus) + $b }
multi infix:<+>(Modulo $a, Modulo $b where $a.modulus ~~ $b.modulus)
is export returns Modulo { Modulo.new: $a.Bridge + $b.Bridge, :modulus($b.modulus) }

multi prefix:<->(Modulo $a)
is export returns Modulo { $a.new: -$a.Bridge, :modulus($a.modulus) }
multi infix:<->(Modulo $a, Modulo $b where $a.modulus ~~ $b.modulus)
is export returns Modulo { $a + -$b }

multi infix:<*>(Int $a, Modulo $b)
is export returns Modulo { Modulo.new: $a * $b.Bridge, :modulus($b.modulus) }
multi infix:<*>(Modulo $a, Modulo $b where $a.modulus ~~ $b.modulus)
is export returns Modulo { Modulo.new: $a.Bridge * $b.Bridge, :modulus($b.modulus) }

multi infix:<div>(Modulo $a, Modulo $b) is export returns Modulo { $a * $b.Inverse }
multi infix:</>(Modulo $a, Modulo $b) is export returns Modulo { $a div $b }

multi infix:<**>(Modulo $a, Int $e) is export returns Modulo {
    Modulo.new: $a.Bridge.expmod($e, $a.modulus), :modulus($a.modulus)
}

# vim: ft=perl6
