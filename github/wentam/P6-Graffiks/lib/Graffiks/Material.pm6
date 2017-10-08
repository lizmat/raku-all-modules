use v6;
#| Represents what a surface should look like
unit class Graffiks::Material is repr('CStruct');
use NativeCall;

has Pointer $.program;
has num32 $.diffuse_intensity;
has CArray[num32] $.diffuse_color;

sub gfks_create_material(int32)
  returns Graffiks::Material
  is native("libgraffiks") { * }

sub gfks_free_material(Graffiks::Material)
  is native("libgraffiks") { * }

sub gfks_set_material_diffuse_color_rgba(Graffiks::Material, num32, num32, num32, num32)
  is native("libgraffiks") { * }

sub gfks_set_material_specularity_hardness(Graffiks::Material, num32)
  is native("libgraffiks") { * }

sub gfks_set_material_specularity_color_rgb(Graffiks::Material, num32, num32, num32)
  is native("libgraffiks") { * }

sub gfks_get_material_specularity_hardness(Graffiks::Material)
  returns num32
  is native("libgraffiks") { * }

sub gfks_get_material_specularity_color_r(Graffiks::Material)
  returns num32
  is native("libgraffiks") { * }

sub gfks_get_material_specularity_color_g(Graffiks::Material)
  returns num32
  is native("libgraffiks") { * }

sub gfks_get_material_specularity_color_b(Graffiks::Material)
  returns num32
  is native("libgraffiks") { * }

sub gfks_get_material_diffuse_color_r(Graffiks::Material)
  returns num32
  is native("libgraffiks") { * }

sub gfks_get_material_diffuse_color_g(Graffiks::Material)
  returns num32
  is native("libgraffiks") { * }

sub gfks_get_material_diffuse_color_b(Graffiks::Material)
  returns num32
  is native("libgraffiks") { * }

sub gfks_get_material_diffuse_color_a(Graffiks::Material)
  returns num32
  is native("libgraffiks") { * }

method new(:$forward, :$deferred) {
  my $flags = 0;

  if ($deferred) {
    $flags +|= 0x01;
  }

  if ($forward) {
    $flags +|= 0x02;
  }

  return gfks_create_material($flags);
}

method set-diffuse-color($r, $g, $b, $a) {
  gfks_set_material_diffuse_color_rgba(self, num32.new($r),
                                             num32.new($g),
                                             num32.new($b),
                                             num32.new($a));
}

method set-specularity-hardness($hardness) {
  gfks_set_material_specularity_hardness(self, num32.new($hardness));
}

method set-specularity-color($r, $g, $b) {
  gfks_set_material_specularity_color_rgb(self, num32.new($r),
                                                num32.new($g),
                                                num32.new($b));
}

method specularity-hardness() {
  return gfks_get_material_specularity_hardness(self);
}

method specularity-color-r() {
  return gfks_get_material_specularity_color_r(self);
}

method specularity-color-g() {
  return gfks_get_material_specularity_color_g(self);
}

method specularity-color-b() {
  return gfks_get_material_specularity_color_b(self);
}

method diffuse-color-r() {
  return gfks_get_material_diffuse_color_r(self);
}

method diffuse-color-g() {
  return gfks_get_material_diffuse_color_g(self);
}

method diffuse-color-b() {
  return gfks_get_material_diffuse_color_b(self);
}

method diffuse-color-a() {
  return gfks_get_material_diffuse_color_a(self);
}

submethod DESTROY {
  gfks_free_material(self);
}
