unit class Pray::Scene::Intersection;

use Pray::Geometry::Ray;
use Pray::Scene::Object;
use Pray::Geometry::Vector3D;

# tested ray
has Pray::Geometry::Ray $.ray;

# collided object
has Pray::Scene::Object $.object;

# tested scene
has $.scene;

# collision position in scene space
has Pray::Geometry::Vector3D $.position =
    $!ray && $!distance ??
        $!ray.position.add(
            $!ray.direction.scale($!distance)
        ) !!
        Pray::Geometry::Vector3D;

# collision distance in ray lengths
has $.distance =
    $!ray && $!position ??
        sqrt(
            $!position.subtract($!ray.position).length_sqr /
            $!ray.direction.length_sqr
        ) !!
        Any;

# surface normal at intersection
has Pray::Geometry::Vector3D $.direction;

# objects which contained the ray before collision
has @.containers =
    ();

# whether we are hitting the inside or outside of the object
has Bool $.exiting =
    $!object ?? $!object ∈ @!containers !! False;


