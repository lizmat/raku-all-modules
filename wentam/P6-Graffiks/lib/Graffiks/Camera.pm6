use v6;
#| Defines where you are looking at your scene from
unit class Graffiks::Camera is repr('CStruct');

use NativeCall;

has num32 $.location_x;
has num32 $.location_y;
has num32 $.location_z;
has num32 $.target_x;
has num32 $.target_y;
has num32 $.target_z;
has num32 $.up_x;
has num32 $.up_y;
has num32 $.up_z;

sub gfks_create_camera()
  returns Graffiks::Camera
  is native("libgraffiks") { * }

sub gfks_destroy_camera(Graffiks::Camera)
  is native("libgraffiks") { * }

sub gfks_set_active_camera(Graffiks::Camera)
  is native("libgraffiks") { * }

sub gfks_set_camera_location(Graffiks::Camera, num32, num32, num32)
  is native("libgraffiks") { * }

sub gfks_set_camera_target(Graffiks::Camera, num32, num32, num32)
  is native("libgraffiks") { * }

sub gfks_rotate_camera(Graffiks::Camera, num32, num32, num32, num32)
  is native("libgraffiks") { * }

sub gfks_get_camera_location_x(Graffiks::Camera)
  returns num32
  is native("libgraffiks") { * }

sub gfks_get_camera_location_y(Graffiks::Camera)
  returns num32
  is native("libgraffiks") { * }

sub gfks_get_camera_location_z(Graffiks::Camera)
  returns num32
  is native("libgraffiks") { * }

sub gfks_get_camera_target_x(Graffiks::Camera)
  returns num32
  is native("libgraffiks") { * }

sub gfks_get_camera_target_y(Graffiks::Camera)
  returns num32
  is native("libgraffiks") { * }

sub gfks_get_camera_target_z(Graffiks::Camera)
  returns num32
  is native("libgraffiks") { * }

method new() {
  return gfks_create_camera();
}

submethod DESTROY {
  gfks_destroy_camera(self);
}

#| Makes this the active camera
method make-active() {
  gfks_set_active_camera(self);
}

#| Sets the location of the camera
method set-location($x, $y, $z) {
  gfks_set_camera_location(self, num32.new($x), num32.new($y), num32.new($z));
}

#| Sets the camera target
method set-target($x, $y, $z) {
  gfks_set_camera_target(self, num32.new($x), num32.new($y), num32.new($z));
}

#| Rotates the camera
method rotate($x, $y, $z, $w) {
  gfks_rotate_camera(self, num32.new($x),
                           num32.new($y),
                           num32.new($z),
                           num32.new($w));
}

method target-x() {
  return gfks_get_camera_target_x(self);
}

method target-y() {
  return gfks_get_camera_target_y(self);
}

method target-z() {
  return gfks_get_camera_target_z(self);
}

method location-x() {
  return gfks_get_camera_location_x(self);
}

method location-y() {
  return gfks_get_camera_location_y(self);
}

method location-z() {
  return gfks_get_camera_location_z(self);
}
