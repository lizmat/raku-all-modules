class Pray::Geometry::Object;

# some of this is messy
    # "primitive" props up loading from scene files
    # "@.csg_obj" should be replaced by custom BUILD to preprocess @.csg?
    # now that csg works (?) it should be refactored
        # too redundant, and awkward params

use Pray::Geometry::Matrix3D;
use Pray::Geometry::Vector3D;
use Pray::Geometry::Ray;

use Pray::Input::JSON;

has Str $.primitive = self.^name ~~ /^'Pray::Geometry::'(.)(.*)$/ ??
    $0.lc~$1 !!
    self.^name;
    
has Pray::Geometry::Vector3D $.position;
has Pray::Geometry::Vector3D $.scale;
has Pray::Geometry::Vector3D $.rotate;

has $.max_radius = sqrt(3);

method _build_transform (
    Bool :$position = True,
    Bool :$scale_inv = False
) {
    my $transform = m3d.identity;
    if ($!scale) {
        my %args = <x y z>.map: { $_ => $!scale."$_"() };
        my $scale_mat = m3d.scale(|%args);
        $scale_mat .= invert if $scale_inv;
        $transform .= multiply( $scale_mat );
    }
    if ($!rotate) {
        my $rotate = self.rotate_radians;
        for <z y x> -> $axis {
            if $rotate."$axis"() -> $angle {
                $transform .= multiply( m3d.rotate($axis, $angle) );
            }
        }
    }
    if $position && $!position {
        my %args = <x y z>.map: { $_ => $!position."$_"() // 0 };
        $transform .= multiply( m3d.translate(|%args) );
    }
    
    return $transform;
}

has Pray::Geometry::Matrix3D $!transform =
    self._build_transform;
has Pray::Geometry::Matrix3D $!transform_dir =
    self._build_transform( :!position );
has Pray::Geometry::Matrix3D $!transform_norm =
    self._build_transform( :!position, :scale_inv );

has Pray::Geometry::Matrix3D $!inv_transform = $!transform.invert;
has Pray::Geometry::Matrix3D $!inv_transform_dir = $!transform_dir.invert;
has Pray::Geometry::Matrix3D $!inv_transform_norm = $!transform_norm.invert;

method _build_csg_obj () {
    self.csg.map: {
        .does(Associative) ??
            Pray::Input::JSON::load_data($_, Pray::Geometry::Object)
        !!
            "$_"
    }
}

has @.csg;
has @!csg_obj = self._build_csg_obj;

multi submethod new (Str :$primitive!, |args) {
    my $class_name = "Pray::Geometry::{$primitive.tc}";
    require ::($class_name);
    my $class = ::($class_name);
    die "Unrecognized object primitive '$primitive' in scene"
        unless $class.isa($?CLASS);
    $class.new(|args);
}

method ray_intersection (
    Pray::Geometry::Ray $orig_ray,
    :$segment = False,
    Bool :$inside = False,
    :$csg = True,
    Bool :$transform is copy = True,
) {
    $transform &&= ?( $!position || $!scale || $!rotate );
    my $ray = $orig_ray;
    
    # transform ray
    $ray .= new(
        position  =>  $orig_ray.position.transform( $!inv_transform ),
        direction => $orig_ray.direction.transform( $!inv_transform_dir )
    ) if $transform;
    
    # intersection and culling
    state %position_bound;
    my $bound := %position_bound{
        "{$ray.position.x} {$ray.position.y} {$ray.position.z}"
    };
    # http://en.wikipedia.org/wiki/Angular_diameter
    $bound //= do {
        my $dist = $ray.position.length;
        # "pi -" here prevents having to reverse one of the vectors later
        # b/c a ray towards the origin has *opposite* position and direction vectors
        $dist > $!max_radius * 1.1 ?? pi - asin($!max_radius * 1.1 / $dist) !! 0;
    };
    my @return;
    @return = self._ray_intersection($ray)
        unless $bound && $bound > $ray.position.angle($ray.direction);

    if $inside { $_[1] .= reverse for @return };

    @return .= grep: {
        $_[2] >= 0 &&
        ( !$segment || $_[2] <= 1 ) &&
        $_[1].dot($ray.direction) < 0
    };

    # CSG
    if $csg && @!csg {
        for @!csg_obj -> $_, $obj {
            last if $obj === $csg;
            
            when any <add union or> {
                @return = self.ray_intersection_csg_add(
                    $ray, $obj, @return, segment => $segment, inside => $inside
                )
            }
            
            when any <subtract not andnot> {
                @return = self.ray_intersection_csg_subtract(
                    $ray, $obj, @return, segment => $segment, inside => $inside
                )
            }
            
            when any <intersect intersection and> {
                @return = self.ray_intersection_csg_intersect(
                    $ray, $obj, @return, segment => $segment, inside => $inside
                )
            }
            
            when any <deintersect difference xor> {
                @return = self.ray_intersection_csg_deintersect(
                    $ray, $obj, @return, segment => $segment, inside => $inside
                )
            }
            
            default { die qq[Unrecognized CSG operation "$_" in scene] }
        }
    }

    # transform results
    for @return -> $result {
        if $transform {
            $result[0] = $result[0].transform($!transform);
            $result[1] = $result[1].transform($!transform_norm).normalize;
        }

        # distance is optional in return from primitives
        $result[2] = $result[0].subtract($orig_ray.position).length /
            $orig_ray.direction.length
            unless !$transform && $result[2].defined;
    }
    
    return @return;
}

method ray_intersection_csg_add (
    $ray, $obj, @return is copy, :$segment, :$inside,
) {
    @return .= grep: { !$obj.contains_point($_[0], csg => self) };
    
    @return.push(
        $obj.ray_intersection(
            $ray, :$segment, :$inside, :csg(self)
        ).grep: { !self.contains_point($_[0], :csg($obj), :!transform) }
    );

    return @return;
}

method ray_intersection_csg_subtract (
    $ray, $obj, @return is copy, :$segment, :$inside, :$transform = True,
) {
    @return .= grep: { !$obj.contains_point($_[0], csg => self, :$transform) };
    
    @return.push(
        $obj.ray_intersection(
            $ray, :$segment, :inside(!$inside), :csg(self), :$transform,
        ).grep: {
            self.contains_point($_[0], :csg($obj), :transform(!$transform))
        }
    );
    
    return @return;
}

method ray_intersection_csg_intersect (
    $ray, $obj, @return is copy, :$segment, :$inside,
) {
    @return .= grep: { $obj.contains_point($_[0], csg => self) };
    
    @return.push(
        $obj.ray_intersection(
            $ray, :$segment, :$inside, csg => self
        ).grep: { self.contains_point($_[0], :csg($obj), :!transform) }
    );

    return @return;
}

method ray_intersection_csg_deintersect (
    $ray, $obj, @return is copy, :$segment, :$inside,
) {
    # (A-B) + (B-A)

    # A - B
    @return = self.ray_intersection_csg_subtract(
        $ray, $obj, @return, :$segment, :$inside,
    );

    # +
    @return.push(
        # B - A
        $obj.ray_intersection_csg_subtract(
            $ray, self,
            $obj.ray_intersection($ray, :$segment, :$inside, :csg(self)),
            :$segment, :$inside, :!transform,
        )
    );

    return @return;
}

method _ray_intersection (Pray::Geometry::Ray $ray) { return }

method contains_point (
    Pray::Geometry::Vector3D $point is copy,
    :$csg = True,
    Bool :$transform = True,
) {
    #transform
    $point .= transform($!inv_transform) if $transform;

    #calculate
    my $return = self._contains_point($point);
    
    #csg
    if $csg {
        for @!csg_obj -> $_, $obj {
            last if $obj === $csg;
            my $result = $obj.contains_point($point);
            when any <add union or>
                { $return ||= $result }
            when any <subtract not andnot>
                { $return &&= !$result }
            when any <intersect intersection and>
                { $return &&= $result }
            when any <deintersect difference xor>
                { $return = ( $return != $result ) }
            default { die qq[Unrecognized CSG operation "$_" in scene] }
        }
    }

    return $return;
}

method _contains_point (Pray::Geometry::Vector3D $point) { return False }

method rotate_radians () {
    self.rotate.scale(pi/180)
}


