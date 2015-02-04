class Pray::Scene;

use Pray::Input::JSON;

use Pray::Scene::Color;
use Pray::Scene::Intersection;

use Pray::Scene::Object;
use Pray::Scene::Light;
use Pray::Scene::Camera;

has Pray::Scene::Object @.objects;
has Pray::Scene::Light @.lights;
has Pray::Scene::Camera $.camera = Pray::Scene::Camera.new;

has Pray::Scene::Color $.sky = black;
has $.refraction = 1;

method load (Str $file) {
    Pray::Input::JSON::load_file($file, self.WHAT);
}

method ray_color (
    Pray::Geometry::Ray $ray,
    :@containers,
    :$recurse,
) {
    self.intersection_color(
        self.ray_intersection($ray, :@containers),
        :$recurse,
    );
}

# some of the stuff in here might be old cruft
method ray_intersection (
    Pray::Geometry::Ray $ray,
    :@containers,
    :$boolean = False,
    :$list = False,
    :$segment = False,
) {
    my @return;
    
    for @(self.objects) -> $obj {
        my $inside = $obj ∈ @containers;
        if $boolean {
            return True if $obj.geometry.ray_intersection(
                $ray,
                :$segment,
                :$inside
            );
        } elsif $list {
            @return.push($obj) if $obj.geometry.ray_intersection(
                $ray,
                :$segment,
                :$inside
            );
        } else {
            my @intersect := $obj.geometry.ray_intersection(
                $ray,
                :$segment,
                :$inside
            );
            next unless @intersect;
            my $u = [min] @intersect.map: {$_[2]};
            next unless !@return || @return[2] > $u;
            my $i = (^@intersect).first: { @intersect[$_][2] == $u };
            @return = @intersect[$i].list, $obj;
        }
    }

    return False if $boolean;

    return @return if $list;

    return Pray::Scene::Intersection.new(
        :$ray,
        object => @return[3],
        scene => self,
        position => @return[0],
        direction => @return[1],
        distance => @return[2],
        :@containers,
    ) if @return;

    return;
}

method intersection_color (
    $intersection,
    :$recurse,
) {
    return $.sky unless $intersection && $intersection.object;

    return $intersection.object.material.intersection_color(
        $intersection,
        $recurse,
    );
}


