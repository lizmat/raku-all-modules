use v6;
unit class Graffiks::Object is repr('CStruct');

use NativeCall;
use Graffiks::Mesh;
use Graffiks::Material;

has CArray $.meshes;
has CArray $.mats;
has int32 $.mesh_count;
has num32 $.location_x;
has num32 $.location_y;
has num32 $.location_z;
has num32 $.angle;
has num32 $.rot_x;
has num32 $.rot_y;
has num32 $.rot_z;

sub gfks_create_object(CArray, CArray, int32)
    returns Graffiks::Object
    is native("libgraffiks") { * }

sub gfks_remove_object(Graffiks::Object)
    is native("libgraffiks") { * }

sub gfks_get_object_x(Graffiks::Object)
    returns num32
    is native("libgraffiks") { * }

sub gfks_get_object_y(Graffiks::Object)
    returns num32
    is native("libgraffiks") { * }

sub gfks_get_object_z(Graffiks::Object)
    returns num32
    is native("libgraffiks") { * }

sub gfks_get_object_angle(Graffiks::Object)
    returns num32
    is native("libgraffiks") { * }

sub gfks_get_object_angle_x(Graffiks::Object)
    returns num32
    is native("libgraffiks") { * }

sub gfks_get_object_angle_y(Graffiks::Object)
    returns num32
    is native("libgraffiks") { * }

sub gfks_get_object_angle_z(Graffiks::Object)
    returns num32
    is native("libgraffiks") { * }

sub gfks_set_object_rotation(Graffiks::Object, num32, num32, num32, num32)
    is native("libgraffiks") { * }

sub gfks_hide_object(Graffiks::Object)
    is native("libgraffiks") { * }

sub gfks_show_object(Graffiks::Object)
    is native("libgraffiks") { * }

method new (@meshes, @mats) {
  my @Cmeshes := CArray[Graffiks::Mesh].new();

  for @meshes.kv -> $i, $mesh {
      @Cmeshes[$i] = $mesh;
  }

  my @Cmats := CArray[Graffiks::Material].new();

  for @mats.kv -> $i, $mat {
    @Cmats[$i] = $mat;
  }

  return gfks_create_object(@Cmeshes, @Cmats, @meshes.elems);
}

method location-x() {
  return gfks_get_object_x(self);
}

method location-y() {
  return gfks_get_object_x(self);
}

method location-z() {
  return gfks_get_object_x(self);
}

method angle-w() {
  return gfks_get_object_angle(self);
}

method angle-x() {
  return gfks_get_object_angle_x(self);
}

method angle-y() {
  return gfks_get_object_angle_y(self);
}

method angle-z() {
  return gfks_get_object_angle_z(self);
}

method show() {
  gfks_show_object(self);
}

method hide() {
  gfks_hide_object(self);
}

multi method set-location($x, $y, $z) {
    $!location_x = num32.new($x);
    $!location_y = num32.new($y);
    $!location_z = num32.new($z);
}

multi method set-location(:$x!, :$y!, :$z!) {
  self.set-location($x, $y, $z);
}

multi method set-rotation($angle, $x, $y, $z) {
    gfks_set_object_rotation(self, num32.new($angle),
                                   num32.new($x),
                                   num32.new($y),
                                   num32.new($z));
}

multi method set-rotation(:$angle!, :$x!, :$y!, :$z!) {
  self.set-rotation($angle, $x, $y, $z);
}

submethod DESTROY {
  gfks_remove_object(self);
}
