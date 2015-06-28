use v6;
unit class Graffiks::Mesh is repr('CStruct');

use NativeCall;
use Graffiks::Material;

# these are the same as the mesh.c "mesh" struct
# because we represent CStruct
has int32 $.triangle_buffer;
has int32 $.normal_buffer;
has int32 $.vertex_color_buffer;
has int32 $.vertex_count;
has int32 $.normal_count;
has num32 $.location_x;
has num32 $.location_y;
has num32 $.location_z;
has num32 $.angle;
has num32 $.rot_x;
has num32 $.rot_y;
has num32 $.rot_z;

sub gfks_create_mesh(CArray, CArray, int32, CArray)
  returns Graffiks::Mesh
  is native("libgraffiks") { * }

sub gfks_create_cube(num32)
  returns Graffiks::Mesh
  is native("libgraffiks") { * }

sub gfks_create_plane(num32, num32)
  returns Graffiks::Mesh
  is native("libgraffiks") { * }

sub gfks_create_triangle(num32)
  returns Graffiks::Mesh
  is native("libgraffiks") { * }

sub gfks_free_mesh(Graffiks::Mesh)
  is native("libgraffiks") { * }

method new(@vertices, @faces, @normals) {
  my @Cvertices := CArray[CArray].new();

  for @vertices.kv -> $i, @vertex {
    @Cvertices[$i] = CArray[num32].new();

    for ^3 -> $j {
      @Cvertices[$i][$j] = num32.new(@vertex[$j]);
    }
  }

  my @Cfaces := CArray[CArray].new();

  for @faces.kv -> $i, @face {
    @Cfaces[$i] = CArray[CArray].new();

    for ^3 -> $j {
      @Cfaces[$i][$j] = CArray[int32].new();

      for ^3 -> $k {
        @Cfaces[$i][$j][$k] = @face[$j][$k];
      }
    }
  }

  my @Cnormals := CArray[CArray].new();

  for @normals.kv -> $i, @normal {
    @Cnormals[$i] = CArray[num32].new();

    for ^3 -> $j {
      @Cnormals[$i][$j] = num32.new(@normal[$j]);
    }
  }

  return gfks_create_mesh(@Cvertices, @Cfaces, @faces.elems, @Cnormals);
}

method new-cube($scale) {
  return gfks_create_cube(num32.new($scale));
}

method new-plane($width, $height) {
  return gfks_create_plane(num32.new($width), num32.new($height));
}

method new-triangle($scale) {
  return gfks_create_triangle(num32.new($scale));
}

submethod DESTROY {
  gfks_free_mesh(self);
}

multi method set_location($x, $y, $z) {
    $!location_x = num32.new($x);
    $!location_y = num32.new($y);
    $!location_z = num32.new($z);
}

multi method set_location(:$x!, :$y!, :$z!) {
  self.set_location($x, $y, $z);
}

multi method set_rotation($angle, $x, $y, $z) {
    $!angle = num32.new($angle);
    $!rot_x = num32.new($x);
    $!rot_y = num32.new($y);
    $!rot_z = num32.new($z);
}

multi method set_rotation(:$angle!, :$x!, :$y!, :$z!) {
  self.set_rotation($angle, $x, $y, $z);
}
