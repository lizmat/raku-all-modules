use v6;
use Pray::Geometry::Object;
unit class Pray::Geometry::Cylinder is Pray::Geometry::Object;

use Pray::Geometry::Vector3D;
use Pray::Geometry::Ray;

has $.max_radius = sqrt(2);

method _contains_point (Pray::Geometry::Vector3D $point) {
    !!( $point.z.abs < 1 && $point.x**2+$point.y**2 < 1 )
}

method _ray_intersection (
    Pray::Geometry::Ray $ray
) {
    my ($ray_pos, $ray_dir) = .position, .direction given $ray;

    # $ray_dir.length_sqr;
    my $a = $ray_dir.x**2 + $ray_dir.y**2;
    
    # $ray_dir.dot( $ray_pos ) * 2;
    my $b = ( $ray_pos.x*$ray_dir.x + $ray_pos.y*$ray_dir.y ) * 2;
    
    # $ray_pos.length_sqr - 1
    my $c = $ray_pos.x**2 + $ray_pos.y**2 - 1;
    
    my $determinant = $b * $b - 4 * $a * $c;
    
    my @return_points;

    if ($determinant >= 0) {
        my $det_root = 0;
        my @list;
        if $determinant > 0 {
            $det_root = sqrt $determinant;
            @list = -1, 1;
        } elsif $a {
            @list = 0;
        }

        if @list {
            my @u = @list.map: { (-$b + $det_root*$_) / (2 * $a) };
            my @p = @u.map: { $ray_pos.add( $ray_dir.scale($_) ) };
            for ^@list -> $i {
                my $z = @p[$i].z;
                if -1 <= $z <= 1 {
                    @return_points.push([
                        $_,
                        v3d(.x, .y, 0),
                        @u[$i]
                    ]) given @p[$i];
                } elsif
                    @list > 1 && (
                        -1 <= @p[1-$i].z <= 1 ||
                        $z.sign != @p[1-$i].z.sign
                    )
                {
                    my $sign = $z.sign;
                    my $u = ($sign - $ray_pos.z) / $ray_dir.z;
                    my $point = $ray_pos.add( $ray_dir.scale($u));
                    @return_points.push([
                        $point,
                        v3d(0, 0, $sign),
                        $u
                    ]);
                }
            }
        } elsif $c <= 0 && $ray_dir.z {
            @list = -1, 1;
            for @list -> $sign {
                my $u = ($sign - $ray_pos.z) / $ray_dir.z;
                my $point = $ray_pos.add( $ray_dir.scale($u));
                @return_points.push([
                    $point,
                    v3d(0, 0, $sign),
                    $u
                ]);
            }
        }
    }
    
    return @return_points;
}


