unit class Pray::Geometry::Matrix3D;

has $.values is rw;

multi sub m3d () is export {
    $?CLASS
}

multi sub m3d (+@values) is export {
    $?CLASS.new( values => @values )
}

method zero () {
    m3d(
        [0,0,0,0],
        [0,0,0,0],
        [0,0,0,0],
        [0,0,0,0]
    )
}

method identity () {
    m3d(
        [1,0,0,0],
        [0,1,0,0],
        [0,0,1,0],
        [0,0,0,1]
    )
}

method translate (:$x = 0, :$y = 0, :$z = 0) {
    m3d(
        [1,0,0,$x],
        [0,1,0,$y],
        [0,0,1,$z],
        [0,0,0, 1]
    )
}

method scale (:$x = 1, :$y = 1, :$z = 1) {
    m3d(
        [$x, 0, 0, 0],
        [ 0,$y, 0, 0],
        [ 0, 0,$z, 0],
        [ 0, 0, 0, 1]
    )
}

method rotate ($axis where enum <x y z>, $angle) {
    $angle ?? {
        my $return = self.identity;
        
        my ($x, $y);
        given $axis {
            when 'x' { ($x, $y) = 1, 2 }
            when 'y' { ($x, $y) = 0, 2 }
            when 'z' { ($x, $y) = 0, 1 }
        }
        
        my ($sin, $cos) = .sin, .cos given $angle;
        
        $return.values[$x][$x] = $cos;
        $return.values[$x][$y] = -$sin;
        $return.values[$y][$x] = $sin;
        $return.values[$y][$y] = $cos;
        
        $return;
    }() !!
        self.clone
    ;
}

method invert () {
    my $i = $!values;

    my $s = [
        $i[0][0] * $i[1][1] - $i[1][0] * $i[0][1],
        $i[0][0] * $i[1][2] - $i[1][0] * $i[0][2],
        $i[0][0] * $i[1][3] - $i[1][0] * $i[0][3],
        $i[0][1] * $i[1][2] - $i[1][1] * $i[0][2],
        $i[0][1] * $i[1][3] - $i[1][1] * $i[0][3],
        $i[0][2] * $i[1][3] - $i[1][2] * $i[0][3]
    ];

    my $c = [
        $i[2][0] * $i[3][1] - $i[3][0] * $i[2][1],
        $i[2][0] * $i[3][2] - $i[3][0] * $i[2][2],
        $i[2][0] * $i[3][3] - $i[3][0] * $i[2][3],
        $i[2][1] * $i[3][2] - $i[3][1] * $i[2][2],
        $i[2][1] * $i[3][3] - $i[3][1] * $i[2][3],
        $i[2][2] * $i[3][3] - $i[3][2] * $i[2][3]
    ];

    my $det =
        $s[0] * $c[5] -
        $s[1] * $c[4] +
        $s[2] * $c[3] +
        $s[3] * $c[2] -
        $s[4] * $c[1] +
        $s[5] * $c[0];
    
    #return self.zero unless $det; # more correct to die here?
    die "Cannot invert zero-determinant matrix:\n{$i.perl}" unless $det;
    
    my $invdet = 1 / $det;

    m3d( [
        ( $i[1][1] * $c[5] - $i[1][2] * $c[4] + $i[1][3] * $c[3]) * $invdet,
        (-$i[0][1] * $c[5] + $i[0][2] * $c[4] - $i[0][3] * $c[3]) * $invdet,
        ( $i[3][1] * $s[5] - $i[3][2] * $s[4] + $i[3][3] * $s[3]) * $invdet,
        (-$i[2][1] * $s[5] + $i[2][2] * $s[4] - $i[2][3] * $s[3]) * $invdet
    ], [
        (-$i[1][0] * $c[5] + $i[1][2] * $c[2] - $i[1][3] * $c[1]) * $invdet,
        ( $i[0][0] * $c[5] - $i[0][2] * $c[2] + $i[0][3] * $c[1]) * $invdet,
        (-$i[3][0] * $s[5] + $i[3][2] * $s[2] - $i[3][3] * $s[1]) * $invdet,
        ( $i[2][0] * $s[5] - $i[2][2] * $s[2] + $i[2][3] * $s[1]) * $invdet
    ], [
        ( $i[1][0] * $c[4] - $i[1][1] * $c[2] + $i[1][3] * $c[0]) * $invdet,
        (-$i[0][0] * $c[4] + $i[0][1] * $c[2] - $i[0][3] * $c[0]) * $invdet,
        ( $i[3][0] * $s[4] - $i[3][1] * $s[2] + $i[3][3] * $s[0]) * $invdet,
        (-$i[2][0] * $s[4] + $i[2][1] * $s[2] - $i[2][3] * $s[0]) * $invdet
    ], [
        (-$i[1][0] * $c[3] + $i[1][1] * $c[1] - $i[1][2] * $c[0]) * $invdet,
        ( $i[0][0] * $c[3] - $i[0][1] * $c[1] + $i[0][2] * $c[0]) * $invdet,
        (-$i[3][0] * $s[3] + $i[3][1] * $s[1] - $i[3][2] * $s[0]) * $invdet,
        ( $i[2][0] * $s[3] - $i[2][1] * $s[1] + $i[2][2] * $s[0]) * $invdet
    ] );
}

method multiply (Pray::Geometry::Matrix3D $m) {
    my @values;
    my ($dim0, $dim1) = $m.values.end, $!values[0].end;
    for 0..$dim0 -> $i {
        @values[$i] = [];
        for 0..$dim1 -> $j {
            my @a_vals = $!values.map({.[$j]});
            my @b_vals = $m.values[$i][];
            my $value = [+]( @a_vals »*« @b_vals );
            @values[$i][$j] = $value;
            
        }
    }
    m3d( |@values );
}



