# P6-Graffiks
perl 6 bindings to [Graffiks](https://github.com/wentam/Graffiks)

## Example usage

The following will create a spinning cube:

```perl6
use v6;
use Graffiks;
use Graffiks::Camera;
use Graffiks::PointLight;
use Graffiks::Mesh;
use Graffiks::Material;
use Graffiks::Object;

Graffiks.new(init => &init,
             update => &update);

my $object;

sub init ($gfks, $window_width, $window_height) {
  # enable the deferred renderer
  $gfks.enable-renderers(:deferred);

  # create, position, and make our camera the active one
  my $camera = Graffiks::Camera.new();
  $camera.make-active();
  $camera.set-location(0,0,7);

  # create and position a point light (without light, you won't see anything!)
  my $light = Graffiks::PointLight.new();
  $light.set-location(0,0,5);

  # create a cube mesh
  my $mesh = Graffiks::Mesh.new-cube(5);

  # create a material
  my $material = Graffiks::Material.new(:deferred);

  # create an object with the previously created mesh and material
  $object = Graffiks::Object.new(Array.new($mesh), Array.new($material));
  $object.set-location(0,0,-10);
}

sub update ($gfks, $time_step) {
  # rotate our object based on $time_step
  my $a = $object.angle-w();
  $object.set-rotation(angle => $a+(0.05*$time_step),
                       x => 0,
                       y => 1,
                       z => 1);
}
```
