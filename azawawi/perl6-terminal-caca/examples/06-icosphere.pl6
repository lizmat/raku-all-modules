#!/usr/bin/env perl6

use v6;

use v6;
use lib 'lib';
use Terminal::Caca;

class Point2D {
    has $.x is rw;
    has $.y is rw;
}

class Point3D {
    constant D = 5;

    has $.x is rw;
    has $.y is rw;
    has $.z is rw;

    method rotate-x($angle) {
        my $radians   = $angle * pi / 180.0;
        my $sin-theta = sin($radians);
        my $cos-theta = cos($radians);
        my $rx        = $!x;
        my $ry        = $!y * $cos-theta - $!z * $sin-theta;
        my $rz        = $!y * $sin-theta + $!z * $cos-theta;
        return Point3D.new( x => $rx, y => $ry, z => $rz )
    }

    method rotate-y($angle) {
        my $radians   = $angle * pi / 180.0;
        my $sin-theta = sin($radians);
        my $cos-theta = cos($radians);
        my $rx        = $!x * $cos-theta - $!z * $sin-theta;
        my $ry        = $!y;
        my $rz        = $!x * $sin-theta + $!z * $cos-theta;
        return Point3D.new( x => $rx, y => $ry, z => $rz )
    }

    method rotate-z($angle) {
        my $radians   = $angle * pi / 180.0;
        my $sin-theta = sin($radians);
        my $cos-theta = cos($radians);
        my $rx        = $!x * $cos-theta - $!y * $sin-theta;
        my $ry        = $!x * $sin-theta + $!y * $cos-theta;
        my $rz        = $!z;
        return Point3D.new( x => $rx, y => $ry, z => $rz )
    }

    method to-point2d returns Point2D {
        my $px = $!x * D / ( D + $!z );
        my $py = $!y * D / ( D + $!z );
        Point2D.new( x => $px, y => $py )
    }
}

# Initialize library
given my $o = Terminal::Caca.new {

    # Set the window title
    .title("Icosphere Animation");

    #
    # http://blog.andreaskahler.com/2009/06/creating-icosphere-mesh-in-code.html
    #
    my $t = (1.0 + sqrt(5.0)) / 2.0;
    my Point3D @p;
    @p.push( Point3D.new( x => -1, y =>  $t, z => 0 ) );
    @p.push( Point3D.new( x =>  1, y =>  $t, z => 0 ) );
    @p.push( Point3D.new( x => -1, y => -$t, z => 0 ) );
    @p.push( Point3D.new( x =>  1, y => -$t, z => 0 ) );

    @p.push( Point3D.new( x =>  0, y => -1, z => $t ) );
    @p.push( Point3D.new( x =>  0, y =>  1, z => $t ) );
    @p.push( Point3D.new( x =>  0, y => -1, z => -$t ) );
    @p.push( Point3D.new( x =>  0, y =>  1, z => -$t ) );

    @p.push( Point3D.new( x =>  $t, y => 0, z => -1 ) );
    @p.push( Point3D.new( x =>  $t, y => 0, z =>  1 ) );
    @p.push( Point3D.new( x => -$t, y => 0, z => -1 ) );
    @p.push( Point3D.new( x => -$t, y => 0, z =>  1 ) );

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

    # Initialize random face colors
    my @colors;
    my $color-index = 0;
    for @faces {
        state $face-index = 0;
        my @color = 15, 0, $color-index % 16, 0;
        $color-index++;
        @colors.push(@color);
    }

    for ^359*10 -> $angle {

        # Clear canvas
        .color(white, white);
        .clear;

        .title(sprintf("Icosphere Animation, angle: %s", $angle % 360));

        # Transform 3D into 2D and rotate for all icosphere faces
        my $face-index = 0;
        my @faces-z;
        for @faces -> @face {
            my @points;
            my @z-points;
            my $sum-z = 0;
            for @face -> $point-index {
                # Rotate around x, y and z
                my $point = @p[$point-index];
                my $pt    = $point.rotate-x($angle);
                $pt       = $pt.rotate-y($angle);
                $pt       = $pt.rotate-z($angle);

                # Transform 3D to 2D
                my $p2d = $pt.to-point2d;
                $p2d.x  = Int($p2d.x * 15 + 40);
                $p2d.y  = Int($p2d.y * 7 + 15);
                @points.push( $p2d );

                # This is going to use to calculate average z value of a
                # 3D triangle
                $sum-z += $pt.z;
            }
            
            # Calculate average z value for all triangle points
            my $avg-z = $sum-z / @points.elems;

            @faces-z.push: %(
                face     => @face,
                color    => @colors[$face-index],
                points   => @points,
                avg-z    => $avg-z,
            );
            $face-index++;
        }

        # Sort by z to draw farthest first
        @faces-z = @faces-z.sort( { %^a<avg-z> <=> %^b<avg-z> } ).reverse;

        # Draw all faces
        for @faces-z -> %rec {
            my @points = @(%rec<points>);
            my @color  = @(%rec<color>);
            
            # Draw filled triangle
            .color(
                @color[0], @color[1], @color[2], @color[3],
                @color[0], @color[1], @color[2], @color[3]
            );
            .fill-triangle(
                @points[0].x, @points[0].y,
                @points[1].x, @points[1].y,
                @points[2].x, @points[2].y,
            );

            .color(black, black);
            .thin-triangle(
                @points[0].x, @points[0].y,
                @points[1].x, @points[1].y,
                @points[2].x, @points[2].y,
            );
        }

        # Refresh to show canvas on terminal
        .refresh;
    }

    # Cleanup on scope exit
    LEAVE {
        .cleanup;
    }

}
