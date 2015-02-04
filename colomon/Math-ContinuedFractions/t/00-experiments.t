use Test;

plan 18;

sub make-continued-fraction (Real $x is copy) {
    gather loop {
        my $a = $x.floor;
        take $a;
        $x = $x - $a;
        last if $x == 0;
        $x = 1 / $x;
    }
}

is make-continued-fraction(3), [3], "Sanity test";
is make-continued-fraction(-42), [-42], "Sanity test";
is make-continued-fraction(3.245), [3, 4, 12, 4], "Wikipedia example works";
is make-continued-fraction(-4.2), [-5, 1, 4], "Wikipedia example works";

multi sub z($a is copy, $b is copy, $c is copy, $d is copy, @x) {
    gather loop {
        # say "abcd: $a $b $c $d";
        my $a-div-c = $c ?? $a div $c !! Inf;
        my $b-div-d = $d ?? $b div $d !! Inf;
        # say "a/c b/d: $a-div-c $b-div-d";
        last if $a-div-c == Inf && $b-div-d == Inf;
        if $a-div-c == $b-div-d {
            my $n = $a-div-c;
            ($a, $b, $c, $d) = ($c, $d, $a - $c * $n, $b - $d * $n);
            take $n;
            # say "took $n";
        } else {
            if @x {
                my $p = @x.shift;
                ($a, $b, $c, $d) = ($b, $a + $b * $p, $d, $c + $d * $p);
                # say "got $p";
            } else {
                ($a, $b, $c, $d) = ($b, $b, $d, $d); # WHY????
                # say "got Inf";
            }
        }
    }
}

is z(1, 2, 2, 0, [1, 5, 2]), [1, 1, 2, 7], "mjd's example works";
is z(1, 0, 1, 0, [1, 2, 3, 4]), [1], "z handles case where it is 0 times x";
is z(1, 0, 1, 0, [0]), [1], "z handles another case where it is 0 times x";
is z(1, 4, 4, 0, make-continued-fraction(22/7)), make-continued-fraction(22/7+1/4), 
   "+1/4 works, with make-continued-fraction";
is z(1, 0, 0, 1, make-continued-fraction(22/7)), make-continued-fraction(7/22), "z works to get reciprocal";

multi sub z($a is copy, $b is copy, $c is copy, $d is copy, 
            $e is copy, $f is copy, $g is copy, $h is copy, 
            @x, @y) {
    my $oops = 0;
    gather loop {
        # say "\n$a $b $c $d $e $f $g $h";
        last if all($e, $f, $g, $h) == 0;
        die "No answer found" if ++$oops > 30;
        
        my $b00 = $e ?? FatRat.new($a, $e) !! Inf;
        my $b10 = $f ?? FatRat.new($b, $f) !! Inf;
        my $b01 = $g ?? FatRat.new($c, $g) !! Inf;
        my $b11 = $h ?? FatRat.new($d, $h) !! Inf;
        # say "$b00  $b01  $b10  $b11";
        
        my $i11 = $b11.floor;
        my $i01 = $b01.floor;
        my $i10 = $b10.floor;
        my $i00 = $b00.floor;

        if $i00 == all($i01, $i10, $i11) {
            my $r = $i00;
            ($a, $b, $c, $d, $e, $f, $g, $h) 
                = ($e, $f, $g, $h, $a - $e * $r, $b - $f * $r, $c - $g * $r, $d - $h * $r);
            take $r;
            # say "r = $r";
            $oops = 0;
        } else {
            sub idiff($a, $b) {
                # $a | $b == Inf ?? Inf !! ($a - $b).abs;
                (($a == Inf ?? 100000000000 !! $a) - ($b == Inf ?? 100000000000 !! $b)).abs;
            }
            
            my $xw = idiff($b11, $b01) max idiff($b10, $b00);
            my $yw = idiff($b11, $b10) max idiff($b01, $b00);
            # say "xw = $xw   yw = $yw";

            if $xw > $yw {
                if @x {
                    my $p = @x.shift;
                    ($a, $b, $c, $d, $e, $f, $g, $h)
                        = ($b, $a + $b * $p, $d, $c + $d * $p, $f, $e + $f * $p, $h, $g + $h * $p);
                    # say "p = $p";
                } else {
                    ($a, $b, $c, $d, $e, $f, $g, $h)
                        = ($b, $b, $d, $d, $f, $f, $h, $h);
                    # say "p = Inf";
                }
            } else {
                if @y {
                    my $q = @y.shift;
                    ($a, $b, $c, $d, $e, $f, $g, $h)
                        = ($c, $d, $a + $c * $q, $b + $d * $q, $g, $h, $e + $g * $q, $f + $h * $q);
                    # say "q = $q";
                } else {
                    ($a, $b, $c, $d, $e, $f, $g, $h)
                        = ($c, $d, $c, $d, $g, $h, $g, $h);
                    # say "q = Inf";
                }
            }
        }
    }
}

is z(1, 2, 0, 0, 2, 0, 0, 0, [1, 5, 2], [1]), [1, 1, 2, 7], "mjd's example works (big z version)";
is z(0, 1, 1, 0, 1, 0, 0, 0, make-continued-fraction(1/4), make-continued-fraction(1/2)),
   make-continued-fraction(1/4+1/2),
   "Basic continued fraction addition";
is z(0, 1, -1, 0, 1, 0, 0, 0, make-continued-fraction(1/4), make-continued-fraction(1/2)), 
   make-continued-fraction(1/4-1/2),
   "Basic continued fraction subtraction";
is z(0, 0, 0, 1, 1, 0, 0, 0, make-continued-fraction(1/4), make-continued-fraction(1/2)), 
   make-continued-fraction(1/4*1/2),
   "Basic continued fraction multiplication";
is z(0, 1, 0, 0, 0, 0, 1, 0, make-continued-fraction(1/4), make-continued-fraction(1/2)), 
   make-continued-fraction(1/4 * 2),
   "Basic continued fraction division";

sub cf-sqrt-two() {
    1, 2, 2, 2 ... *;
}

is cf-sqrt-two()[^10], make-continued-fraction(sqrt(2))[^10], "approximation for sqrt-2 works";
is z(0, 1, 1, 0, 1, 0, 0, 0, cf-sqrt-two(), make-continued-fraction(1/2))[^10],
   make-continued-fraction(sqrt(2)+1/2)[^10],
   "Extended continued fraction addition";
is z(0, 1, 1, 0, 1, 0, 0, 0, cf-sqrt-two(), cf-sqrt-two())[^10],
   make-continued-fraction(sqrt(2)*2)[^10],
   "Extended continued fraction addition";
eval_dies_ok "z(0, 0, 0, 1, 1, 0, 0, 0, cf-sqrt-two(), cf-sqrt-two())[0]", "sqrt(2)^2 cannot be calculated";
