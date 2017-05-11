
#!/usr/bin/env perl6

use v6;

use v6;
use lib 'lib';
use Terminal::Caca;

# Initialize library
given my $o = Terminal::Caca.new {

    # Set the window title
    .title("Icosphere Animation");

    sub to_2d($x, $y, $z) {
        constant D = 5;
        my $px = $x * D / ( D + $z );
        my $py = $y * D / ( D + $z );
        $px, $py
    }

    sub rotate3d-x($x, $y, $z, $angle) {
        my $radians   = $angle * pi / 180.0;
        my $sin-theta = sin($radians);
        my $cos-theta = cos($radians);
        my $rx        = $x;
        my $ry        = $y * $cos-theta - $z * $sin-theta;
        my $rz        = $y * $sin-theta + $z * $cos-theta;
        $rx, $ry, $rz;
    }

    sub rotate3d-y($x, $y, $z, $angle) {
        my $radians   = $angle * pi / 180.0;
        my $sin-theta = sin($radians);
        my $cos-theta = cos($radians);
        my $rx        = $x * $cos-theta - $z * $sin-theta;
        my $ry        = $y;
        my $rz        = $x * $sin-theta + $z * $cos-theta;
        $rx, $ry, $rz;
    }

    sub rotate3d-z($x, $y, $z, $angle) {
        my $radians   = $angle * pi / 180.0;
        my $sin-theta = sin($radians);
        my $cos-theta = cos($radians);
        my $rx        = $x * $cos-theta - $y * $sin-theta;
        my $ry        = $x * $sin-theta + $y * $cos-theta;
        my $rz        = $z;
        $rx, $ry, $rz;
    }

    #
    # http://blog.andreaskahler.com/2009/06/creating-icosphere-mesh-in-code.html
    #
    my $t = (1.0 + sqrt(5.0)) / 2.0;
    my @p;
    @p.push([ -1,  $t,  0 ]);
    @p.push([  1,  $t,  0 ]);
    @p.push([ -1, -$t,  0 ]);
    @p.push([  1, -$t,  0 ]);

    @p.push([  0, -1,  $t ]);
    @p.push([  0,  1,  $t ]);
    @p.push([  0, -1, -$t ]);
    @p.push([  0,  1, -$t ]);

    @p.push([  $t,  0, -1 ]);
    @p.push([  $t,  0,  1 ]);
    @p.push([ -$t,  0, -1 ]);
    @p.push([ -$t,  0,  1 ]);
    
    # create 20 triangles of the icosahedron
    my @faces;

    # 5 faces around point 0
    @faces.push([0, 11, 5]);
    @faces.push([0, 5, 1]);
    @faces.push([0, 1, 7]);
    @faces.push([0, 7, 10]);
    @faces.push([0, 10, 11]);

    # 5 adjacent faces
    @faces.push([1, 5, 9]);
    @faces.push([5, 11, 4]);
    @faces.push([11, 10, 2]);
    @faces.push([10, 7, 6]);
    @faces.push([7, 1, 8]);

    # 5 faces around point 3
    @faces.push([3, 9, 4]);
    @faces.push([3, 4, 2]);
    @faces.push([3, 2, 6]);
    @faces.push([3, 6, 8]);
    @faces.push([3, 8, 9]);

    # 5 adjacent faces
    @faces.push([4, 9, 5]);
    @faces.push([2, 4, 11]);
    @faces.push([6, 2, 10]);
    @faces.push([8, 6, 7]);
    @faces.push([9, 8, 1]);

    sub transform-point($point, $angle) {
        my $x         = @p[$point][0];
        my $y         = @p[$point][1];
        my $z         = @p[$point][2];
        ($x, $y, $z)  = rotate3d-x($x, $y, $z, $angle);
        ($x, $y, $z)  = rotate3d-y($x, $y, $z, $angle);
        ($x, $y, $z)  = rotate3d-z($x, $y, $z, $angle);
        my ($px, $py) = to_2d($x, $y, $z);
        $px           = $px * 15 + 40;
        $py           = $py * 7 + 15;
        $px, $py, $z
    }

    my @colors;
    for @faces {
        my $color = CacaColor((blue..white).pick);
        @colors.push($color);
    }
    for ^359*2 -> $angle {
        .color(white,black);
        .clear;
        my $face-index = 0;
        my @faces-z;
        for @faces -> @face {
            my @points;
            my @z-points;
            for @face -> $point {
                my ($px, $py, $z) = transform-point($point, $angle);
                @points.push( ($px.Int, $py.Int ));
                #@z-points.push( z => $z, points => @points );
            }
            my $center-x = (@points[0][0] + @points[1][0] + @points[2][0]) / 3;
            my $center-y = (@points[0][1] + @points[1][1] + @points[2][1]) / 3;
            #say "$center-x, $center-y";
            my $distance = sqrt($center-x ** 2 + $center-y ** 2);
            @faces-z.push: %(
                    face => @face,
                    color => @colors[$face-index],
                    points => @points,
                    distance => $distance
            );
            $face-index++;
        }

        #@faces-z = @faces-z.sort( {$^b<distance> leg $^a<distance>}, :More);
        for @faces-z -> %rec {
            my @points = @(%rec<points>);
            my $color  = %rec<color>;

            # http://stackoverflow.com/questions/524755/finding-center-of-2d-triangle
            #die "Zzzz: $distance";

            .color($color, $color);
            #.fill-triangle(
            .thin-triangle(
                @points[0][0],@points[0][1],
                @points[1][0],@points[1][1],
                @points[2][0],@points[2][1],
            );
        }
        .refresh;
        sleep 0.042 / 2;
    }

    # Cleanup on scope exit
    LEAVE {
        .cleanup;
    }

}
