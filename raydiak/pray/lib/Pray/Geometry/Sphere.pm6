use v6;
use Pray::Geometry::Object;
unit class Pray::Geometry::Sphere is Pray::Geometry::Object;

use Pray::Geometry::Vector3D;
use Pray::Geometry::Ray;

has $.max_radius = 1;

method _contains_point (Pray::Geometry::Vector3D $point) {
    return !!($point.length_sqr < 1);
}

method _ray_intersection (
    Pray::Geometry::Ray $ray
) {
    my ($ray_pos, $ray_dir) = .position, .direction given $ray;

    my $a = $ray_dir.length_sqr;
    my $b = $ray_dir.dot( $ray_pos ) * 2;
    my $c = $ray_pos.length_sqr - 1;
    my $determinant = $b * $b - 4 * $a * $c;
    
    my @return_points;

    if ($determinant >= 0) {
        my @list = -1, 1;
        my $det_root = 0;
        if $determinant == 0 {
            @list = 0;
        } else {
            $det_root = sqrt $determinant;
        }
        
        for @list -> $sign {
            my $u = (-$b + $sign * $det_root) / (2 * $a);
            
            my $point = $ray_pos.add(
                $ray_dir.scale($u)
            );

            @return_points.push([
                $point,
                $point, # conveniently, for a unit sphere, normal == coords
                $u
            ]);
        }
    }

    return @return_points;
}


