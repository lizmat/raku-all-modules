use v6;
use Pray::Geometry::Object;
class Pray::Geometry::Cone is Pray::Geometry::Object;

use Pray::Geometry::Vector3D;
use Pray::Geometry::Ray;

has $.max_radius = sqrt(2);

method _contains_point (Pray::Geometry::Vector3D $point) {
    $point.z.abs < 1 &&
    $point.x**2 + $point.y**2 < ( .5 - $point.z / 2 )**2
}

method _ray_intersection (
    Pray::Geometry::Ray $ray
) {
    my ($ray_pos, $ray_dir) = .position, .direction given $ray;
    my $ray_pos_z = ($ray_pos.z - 1) / 2;
    my $ray_dir_z = $ray_dir.z / 2;

    my $a =
        $ray_dir.x**2 +
        $ray_dir.y**2 -
        $ray_dir_z**2;
    
    my $b = (
        $ray_pos.x * $ray_dir.x +
        $ray_pos.y * $ray_dir.y -
        $ray_pos_z * $ray_dir_z
    ) * 2;
    
    my $c = $ray_pos.x**2 + $ray_pos.y**2 - $ray_pos_z**2;
    
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
                if -1 <= @p[$i].z <= 1 {
                    @return_points.push([
                        $_,
                        v3d(.x, .y, 0)\
                            .normalize\
                            .add( v3d(0, 0, .5) )\
                            .scale( 1 / sqrt(1.25) ), # norm w/known length
                        @u[$i]
                    ]) given @p[$i];
                } elsif @list > 1 && (-1 <= @p[1-$i].z <= 1) {
                    my $u = (-1 - $ray_pos.z) / $ray_dir.z;
                    my $point = $ray_pos.add( $ray_dir.scale($u) );
                    @return_points.push([
                        $point,
                        v3d(0, 0, -1),
                        $u
                    ]);
                }
            }
        }
    }
    
    return @return_points;
}


