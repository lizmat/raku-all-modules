use v6;

class Math::ChebyshevPolynomial {
    has $.domain;
    has @.c;

    method approximate(Range $domain, $n, &f) {
        my $bma = ($domain.max - $domain.min) / 2;
        my $bpa = ($domain.max + $domain.min) / 2;
        my @f = (^$n).map({ &f(cos(pi * ($_ + 1/2) / $n) * $bma + $bpa) });
        
        my $fac = 2 / $n;
        my @c;
        for ^$n -> $j {
            @c[$j] = $fac * [+] @f <<*>> (^$n).map({ cos(pi * $j * ($_ + 1/2) / $n) });
        }
        self.new(:$domain, :@c);
    }

    method derivative() {
        my @cder = 0 xx +@.c;
        @cder[*-2] = 2 * (@.c - 1) * @.c[*-1];
        for (0..(@.c - 3)).reverse -> $j {
            @cder[$j] = @cder[$j + 2] + 2 * ($j + 1) * @.c[$j + 1];
        }
        @cder = @cder >>*>> (2 / ($.domain.max - $.domain.min));
        self.new(:domain($.domain), :c(@cder));
    }

    method evaluate($x) {
        die '$x not in range in Math::ChebyshevPolynomial::Evaluate' unless $x ~~ $.domain;
        my $y = (2 * $x - $.domain.min - $.domain.max) / ($.domain.max - $.domain.min);
        my $y2 = 2 * $y;
        my $d = 0.0;
        my $dd = 0.0;
        for (1..(@.c - 1)).reverse -> $j {
            ($d, $dd) = ($y2 * $d - $dd + @.c[$j], $d);
        }
        $y * $d - $dd + @.c[0] / 2;
    }
}