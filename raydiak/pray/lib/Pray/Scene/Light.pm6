use v6;

use Pray::Scene::Lighting;

unit class Pray::Scene::Light is Pray::Scene::Lighting;

use Pray::Geometry::Vector3D;
use Pray::Geometry::Ray;
use Pray::Scene::Color;
use Pray::Scene::Intersection;

has Pray::Geometry::Vector3D $.position;

method intersection_color (
    Pray::Scene::Intersection $int
) {
    my $shadow = white;
    
    if $int.scene {
        my $ray_to_light = Pray::Geometry::Ray.new(
            position => $int.position,
            direction => $.position.subtract($int.position)
        );
        
        # objects between light and intersection
        my @obstructions = $int.scene.ray_intersection(
            $ray_to_light,
            list => True,
            segment => True,
            containers => $int.containers
        );

        # obstructing objects which are not opaque
        my @filters = @obstructions.flatmap: {
            (my $t = .material.transparent) && $t.intensity ??
                $t
            !!
                ()
        };

        # light is obstructed by something opaque
        return black if @obstructions > @filters;
        
        $shadow .= scale(.color_scaled) for @filters;
    }

    return self.point_color($int.position).scale($shadow);
}

method point_color (Pray::Geometry::Vector3D $point) {
    my $light_dist_sqr = $.position.subtract($point).length_sqr;
    my $light_falloff = 1 / (1 + $light_dist_sqr);
    return self.color_scaled.scale($light_falloff);
}

