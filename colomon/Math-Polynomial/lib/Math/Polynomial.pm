use v6;

class Math::Polynomial {
    has @.coefficients;
    has $.coeff-zero = 0;
    has $.coeff-one = 1;

    multi method new (*@coefficients) {
        self.new(@coefficients);
    }

    multi method new (@x is copy) {
        while @x && @x[*-1].abs < 1e-13 {
            @x.pop;
        }

        self.bless(coefficients => @x);
    }

    method Str() returns Str {
        @.coefficients.kv.map({ "$^value x^$^key" }).reverse.join(' + ');
    }

    method perl() returns Str {
        "Math::Polynomial.new(" ~ @.coefficients».perl.join(', ') ~ ")";
    }

    method Bool() { self.is-nonzero }

    method evaluate($x) {
        @.coefficients ?? @.coefficients.reverse.reduce({ $^a * $x + $^b }) !! self.coeff-zero;
    }

    method degree() { self.is-nonzero ?? @.coefficients - 1 !! -Inf }

    method is-zero() { @.coefficients == 0 || (@.coefficients == 1 && @.coefficients[0] == 0) }
    method is-nonzero() { !self.is-zero; }
    method is-monic() { self.coefficients > 0 && self.coefficients[*-1] == 1 }

    method monize() {
        return self if self.is-zero || self.is-monic;
        return self / self.coefficients[*-1];
    }

    multi sub infix:<==>(Math::Polynomial $a, Math::Polynomial $b) is export(:DEFAULT) {
        my $max =   $a.coefficients.elems
                max $b.coefficients.elems;

        all((    $a.coefficients, 0 xx *
             Z== $b.coefficients, 0 xx * )[^$max]);
    }
    multi sub infix:<!=>(Math::Polynomial $a, Math::Polynomial $b) is export(:DEFAULT) {
        !($a == $b);
    }

    multi sub infix:<+>(Math::Polynomial $a, Math::Polynomial $b) is export(:DEFAULT) {
        my $max =   $a.coefficients.elems
                max $b.coefficients.elems;

        $a.new: (    $a.coefficients, 0 xx *
                  Z+ $b.coefficients, 0 xx * )[^$max];
    }

    multi sub infix:<+>(Math::Polynomial $a, $b) is export(:DEFAULT) {
        my @ac = $a.coefficients;
        @ac[0] += $b;
        return $a.new(@ac);
    }

    multi sub infix:<+>($b, Math::Polynomial $a) is export(:DEFAULT) {
        $a + $b;
    }

    multi sub prefix:<->(Math::Polynomial $a) is export(:DEFAULT) {
        $a.new($a.coefficients.map({-$_}));
    }

    multi sub infix:<->(Math::Polynomial $a, Math::Polynomial $b) is export(:DEFAULT) {
        -$b + $a;
    }

    multi sub infix:<->(Math::Polynomial $a, $b) is export(:DEFAULT) {
        my @ac = $a.coefficients;
        @ac[0] -= $b;
        return $a.new(@ac);
    }

    multi sub infix:<->($b, Math::Polynomial $a) is export(:DEFAULT) {
        -$a + $b;
    }

    multi sub infix:<*>(Math::Polynomial $a, Math::Polynomial $b) is export(:DEFAULT) {
        my @coef;
        for     $a.coefficients.kv -> $ak, $av {
            for $b.coefficients.kv -> $bk, $bv {
                @coef[ $ak + $bk ] += $av * $bv;
            }
        }

        return $a.new(@coef);
    }

    multi sub infix:<*>(Math::Polynomial $a, $b) is export(:DEFAULT) {
        $a.new($a.coefficients »*» $b);
    }

    multi sub infix:<*>($b, Math::Polynomial $a) is export(:DEFAULT) {
        $a.new($a.coefficients »*» $b);
    }

    multi sub infix:</>(Math::Polynomial $a, $b) is export(:DEFAULT) {
        $a.new($a.coefficients »/» $b);
    }

    multi sub infix:<**>(Math::Polynomial $a, Int $b where $b >= 0) is export(:DEFAULT) {
        $b == 0 ?? Math::Polynomial.new(1)
                !! ($a xx $b).reduce(* * *);
    }

    method divmod(Math::Polynomial $that) {
        my @den = $that.coefficients;
        @den or fail 'division by zero polynomial';
        my $hd = @den.pop;
        if $that.is-monic {
            $hd = Any;
        }
        my @rem = self.coefficients;
        my @quot;
        my $i = (@rem - 1) - @den;
        while (0 <= $i) {
            my $q = @rem.pop;
            if $hd.defined {
                $q /= $hd;
            }
            @quot[$i] = $q;
            my $j = $i--;
            for @den -> $d {
                @rem[$j++] -= $q * $d;
            }
        }
        return Math::Polynomial.new(@quot), Math::Polynomial.new(@rem);
    }

    multi sub infix:</>(Math::Polynomial $a, Math::Polynomial $b) is export(:DEFAULT) {
        $a.divmod($b)[0];
    }

    multi sub infix:<%>(Math::Polynomial $a, Math::Polynomial $b) is export(:DEFAULT) {
        $a.divmod($b)[1];
    }

    method mmod(Math::Polynomial $that) {
        my @den  = $that.coefficients;
        @den or fail 'division by zero polynomial';
        my $hd = @den.pop;
        if $that.is-monic {
            $hd = Any;
        }
        my @rem = self.coefficients;
        my $i = (@rem - 1) - @den;
        while (0 <= $i) {
            my $q = @rem.pop;
            if $hd.defined {
                @rem = @rem »*» $hd;
            }
            my $j = $i--;
            for @den -> $d {
                @rem[$j++] -= $q * $d;
            }
        }
        return Math::Polynomial.new(@rem);
    }

    method pow-mod(Int $exp is copy where $exp >= 0, Math::Polynomial $that) {
        my $this = self % $that;
        return $this.new                                if 0 == $that.degree;
        return $this.new($this.coeff-one)               if 0 == $exp;
        return $this                                    if $this.is-zero;
        return $this.new($this.coefficients[0] ** $exp) if 0 == $this.degree;
        my $result = Any;
        while $exp {
            if 1 +& $exp {
                $result = $result.defined ?? ($this * $result) % $that !! $this;
            }
            $exp +>= 1 and $this = ($this * $this) % $that;
        }
        return $result;
    }

    method shift-up(Int $n where { $n >= 0 }) {
        Math::Polynomial.new(0 xx $n, self.coefficients);
    }

    method shift-down(Int $n where { $n >= 0}) {
        Math::Polynomial.new(self.coefficients()[$n .. *-1]);
    }

    method slice(Int $start where { $start >= 0 },
                 Int $count where { $count >= 0 }) {
        my $degree = self.degree;
        my $end = $start + $count - 1;
        if $degree <= $end {
            return self if 0 == $start;
            $end = $degree;
        }
        return self.new(self.coefficients()[$start .. $end]);
    }

    method nest(Math::Polynomial $that) {
        my $i = self.degree;
        my $result = $that.new(0 <= $i ?? self.coefficients()[$i] !! ());
        while (0 <= --$i) {
            $result = $result * $that + self.coefficients()[$i];
        }
        return $result;
    }

    method mul-root($root) {
        return self.shift-up(1) - self * $root;
    }

    method monomial(Int $degree where { $degree >= 0 }, $coeff? is copy) {
        my $zero;
        # croak 'exponent too large'
        #     if defined($max_degree) && $degree > $max_degree;
        if self.defined {
            if !$coeff.defined {
                $coeff = self.coeff-one;
            }
            $zero  = self.coeff-zero;
        }
        else {
            if !$coeff.defined {
                $coeff = 1;
            }
            $zero  = $coeff - $coeff;
        }
        return self.new($zero xx $degree, $coeff);
    }

    method interpolate(@xvalues, @yvalues where { @yvalues == @xvalues }) {
        return self.new unless @xvalues;
        my @alpha  = @yvalues;
        my $result = self.new(@alpha[0]);
        my $aux    = $result.monomial(0);
        my $zero   = $result.coeff-zero;
        for 1..^@alpha -> $k {
            for ($k..^@alpha).reverse -> $j {
                my $dx = @xvalues[$j] - @xvalues[$j-$k];
                fail 'x values not disjoint' if $zero == $dx;
                @alpha[$j] = (@alpha[$j] - @alpha[$j-1]) / $dx;
            }
            $aux = $aux.mul-root(@xvalues[$k-1]);
            $result += $aux * @alpha[$k];
        }
        return $result;
    }

    method differentiate() {
        self.new((1..self.degree).map({ self.coefficients[$_] * $_ }));
    }

    method integrate($const = self.coeff-zero) {
        self.new($const, (0..self.degree).map({ self.coefficients()[$_] / ($_+1) }));
    }

    method definite_integral($lower, $upper) {
        my $ad = self.integrate;
        return $ad.evaluate($upper) - $ad.evaluate($lower);
    }

    method gcd(Math::Polynomial $that is copy, &mod = * % *) {
        my $this = self;
        my ($this_d, $that_d) = ($this.degree, $that.degree);
        if $this_d < $that_d {
            ($this, $that) = ($that, $this);
            ($this_d, $that_d) = ($that_d, $this_d);
        }
        
        while 0 <= $that_d {
            ($this, $that) = ($that, &mod($this, $that));
            ($this_d, $that_d) = ($that_d, $that.degree);
            $this_d > $that_d or fail 'bad modulo operator';
        }
        return $this;
    }

    method xgcd(Math::Polynomial $that is copy) {
        my $this = self;
        my ($d1, $d2) = ($this.new($this.coeff-one), $this.new);
        if $this.degree < $that.degree {
            ($this, $that) = ($that, $this);
            ($d1, $d2) = ($d2, $d1);
        }

        my ($m1, $m2) = ($d2, $d1);
        while (!$that.is-zero) {
            my ($div, $mod) = $this.divmod($that);
            ($this, $that) = ($that, $mod);
            ($d1, $d2, $m1, $m2) =
                ($m1, $m2, $d1 - $m1 * $div, $d2 - $m2 * $div);
        }
        return ($this, $d1, $d2, $m1, $m2);
    }

    method inv-mod(Math::Polynomial $that) {
        my ($d, $d2) = ($that.xgcd(self))[0, 2];
        fail 'division by zero polynomial' if $that.is-zero || $d2.is-zero;
        return $d2 / $d.coefficients()[*-1];
    }

    method from-roots(*@roots) {
        my $one = self.defined ?? self.coeff-one !! (@roots ?? @roots[*-1] ** 0 !! 1);
        my $result = self.new($one);
        for @roots -> $root {
            $result = $result.mul-root($root);
        }
        return $result;
    }

    method divmod-root($root) {
        my $i   = self.degree;
        my $rem = $i >= 0 ?? self.coefficients()[$i] !! self.coeff-zero;
        my @quot;
        while 0 <= --$i {
            @quot[$i] = $rem;
            $rem = $root * $rem + self.coefficients()[$i];
        }
        return (self.new(@quot), self.new($rem));
    }

    method div-root($root) {
        my ($quot, $rem) = self.divmod-root($root);
        return $quot;
    }

}
