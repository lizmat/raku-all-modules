use v6;
use Pray::Geometry::Object;
class Pray::Geometry::Cube is Pray::Geometry::Object;

use Pray::Geometry::Vector3D;
use Pray::Geometry::Ray;

has $.max_radius = sqrt(3); # is the default, just here for consistency

method _contains_point (Pray::Geometry::Vector3D $point) {
    for $point.x, $point.y, $point.z {
        return False unless $_.abs < 1; 
    }

    return True;
}

method _ray_intersection (Pray::Geometry::Ray $ray) {
    my ($ray_pos, $ray_dir) = .position, .direction given $ray;

    my @axii = <x y z>;
    my @return;
    
    OUTER: for @axii -> $a {
        my $dir = $ray_dir."$a"();
        next unless $dir;

        my $pos = $ray_pos."$a"();

        my @u = (-1, 1).map: { ($_ - $pos) / $dir };
        my @p = @u.map: { $ray_pos.add( $ray_dir.scale($_) ) };
        my @o_a = @axii.grep: {$_ ne $a};

        for ^@p -> $i {
            my $p = @p[$i];
            
            next unless 
                $p."@o_a[0]"().abs <= 1 &&
                $p."@o_a[1]"().abs <= 1;
                
            my @norm = @axii.map: { $_ eq $a ??
                $p."$_"().sign
            !!
                0
            };
            
            @return.push([ $p, v3d(|@norm), @u[$i] ]);
            
            last OUTER if @return >= 2;
        }
    }
    
    return @return;
}


