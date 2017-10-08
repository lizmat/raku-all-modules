use v6;

sub make-continued-fraction (Real $x is copy) {
    gather loop {
        my $a = $x.floor;
        take $a;
        $x = $x - $a;
        last if $x == 0;
        $x = 1 / $x;
    }
}

sub z($a is copy, $b is copy, $c is copy, $d is copy, 
      $e is copy, $f is copy, $g is copy, $h is copy, 
      @x is copy, @y is copy) {
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

class Math::ContinuedFraction {
    has Int @.a;

    multi method new(Math::ContinuedFraction $cf) {
        self.bless(:a($cf.a));
    }
    
    multi method new(@a is copy) {
        self.bless(:@a);
    }

    multi method new(Real $x) {
        self.bless(:a(make-continued-fraction($x)));
    }

    method abs() {
        @.a[0] < 0 ?? 0 - self !! Math::ContinuedFraction.new(self);
    }

    method sign() {
        if  @.a[0] == 0 && !(@.a[1].defined) {
            0
        } else {
            @.a[0] < 0 ?? -1 !! 1
        }
    }

    method truncate() {
        @.a[0] < 0 && @.a[1].defined ?? @.a[0] + 1 !! @.a[0];
    }

    method floor() {
        @.a[0];
    }

    method ceiling() {
        @.a[1].defined ?? @.a[0] + 1 !! @.a[0];
    }

    method round($scale = 1) {
        (self / $scale + 0.5).floor * $scale;
    }
}

# multi sub trait_mod:<is>(Routine $r, :$commutative!) {
#     
# }

multi sub infix:<+>(Math::ContinuedFraction $x, Math::ContinuedFraction $y) is export {
    Math::ContinuedFraction.new(z(0, 1, 1, 0, 1, 0, 0, 0, $x.a, $y.a));
}

multi sub infix:<+>(Math::ContinuedFraction $x, $y) is export {
    $x + Math::ContinuedFraction.new($y);
}

multi sub infix:<+>($y, Math::ContinuedFraction $x) is export {
    $x + Math::ContinuedFraction.new($y);
}

multi sub infix:<->(Math::ContinuedFraction $x, Math::ContinuedFraction $y) is export {
    Math::ContinuedFraction.new(z(0, 1, -1, 0, 1, 0, 0, 0, $x.a, $y.a));
}

multi sub infix:<->(Math::ContinuedFraction $x, $y) is export {
    $x - Math::ContinuedFraction.new($y);
}

multi sub infix:<->($x, Math::ContinuedFraction $y) is export {
    Math::ContinuedFraction.new($x) - $y;
}

multi sub infix:<*>(Math::ContinuedFraction $x, Math::ContinuedFraction $y) is export {
    Math::ContinuedFraction.new(z(0, 0, 0, 1, 1, 0, 0, 0, $x.a, $y.a));
}

multi sub infix:<*>(Math::ContinuedFraction $x, $y) is export {
    $x * Math::ContinuedFraction.new($y);
}

multi sub infix:<*>($y, Math::ContinuedFraction $x) is export {
    $x * Math::ContinuedFraction.new($y);
}

multi sub infix:</>(Math::ContinuedFraction $x, Math::ContinuedFraction $y) is export {
    Math::ContinuedFraction.new(z(0, 1, 0, 0, 0, 0, 1, 0, $x.a, $y.a));
}

multi sub infix:</>(Math::ContinuedFraction $x, $y) is export {
    $x / Math::ContinuedFraction.new($y);
}

multi sub infix:</>($x, Math::ContinuedFraction $y) is export {
    Math::ContinuedFraction.new($x) / $y;
}

