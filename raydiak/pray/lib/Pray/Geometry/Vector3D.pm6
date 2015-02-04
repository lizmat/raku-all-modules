class Pray::Geometry::Vector3D;

# TODO add some in-place options to reduce creation overhead and gc thrash

use Pray::Geometry::Matrix3D;

has $.x = 0;
has $.y = 0;
has $.z = 0;



our sub v3d ($x, $y, $z) is export {
    $?CLASS.bless: :$x, :$y, :$z
}



method v3d ($x, $y, $z, :$in) {
    $in ?? self.set($x,$y,$z) !! v3d($x,$y,$z);
}



has $!length_sqr;
method length_sqr () {
    $!length_sqr //= $!x*$!x + $!y*$!y + $!z*$!z;
}



has $!length;
method length () {
    $!length //= do {
        my $sqr = self.length_sqr;
        !$sqr || $sqr == 1 ?? $sqr !! sqrt $sqr;
    };
}



method set ($x, $y, $z) {
    $!x = $x;
    $!y = $y;
    $!z = $z;
    $!length = Any;
    $!length_sqr = Any;

    self;
}



method normalize (Numeric $length = 1, :$in) {
    my $current_length_sqr = self.length_sqr;
    
    $current_length_sqr != 0 && $current_length_sqr != $length*$length ??
        self.scale( $length / sqrt($current_length_sqr), :$in )
    !!
        $in ?? self !! self.clone
    ;
}



method add (Pray::Geometry::Vector3D $vector, :$in) {
    self.v3d(
        $!x + $vector.x,
        $!y + $vector.y,
        $!z + $vector.z,
        :$in
    )
}



method subtract (Pray::Geometry::Vector3D $vector, :$in) {
    self.v3d(
        $!x - $vector.x,
        $!y - $vector.y,
        $!z - $vector.z,
        :$in
    )
}



method dot (Pray::Geometry::Vector3D $vector) {
    $!x * $vector.x +
    $!y * $vector.y +
    $!z * $vector.z
}



method cross (Pray::Geometry::Vector3D $vector, :$in) {
    self.v3d(
        $!y * $vector.z - $!z * $vector.y,
        $!z * $vector.x - $!x * $vector.z,
        $!x * $vector.y - $!y * $vector.x,
        :$in
    )
}



method angle (Pray::Geometry::Vector3D $vector) {
    acos self.angle_cos($vector)
}



method angle_cos (Pray::Geometry::Vector3D $vector) {
    self.dot($vector) /
    ( self.length * $vector.length )
}



multi method scale (
    Numeric $scale,
    Pray::Geometry::Vector3D :$center,
    :$in
) {
    $center ??
        self.subtract($center, :$in).scale($scale, :in).add($center, :in)
    !! self.v3d(
        $!x * $scale,
        $!y * $scale,
        $!z * $scale,
        :$in
    )
}



multi method scale (
    Pray::Geometry::Vector3D $scale,
    Pray::Geometry::Vector3D :$center,
    :$in
) {
    $center ??
        self.subtract($center, :$in).scale($scale, :in).add($center, :in)
    !! self.v3d(
        $!x * $scale.x,
        $!y * $scale.y,
        $!z * $scale.z,
        :$in
    )
}



method reflect (Pray::Geometry::Vector3D $vector, :$in) {
    $vector.scale(2 * self.dot($vector), :$in).subtract(self, :in)
}



method reverse (:$in) {
    self.v3d( -$!x, -$!y, -$!z, :$in)
}



multi method rotate (
    $axis where enum <x y z>,
    $angle,
    Pray::Geometry::Vector3D :$center,
    :$in
) {
    $center ??
        self.subtract($center, :$in).rotate($axis, $angle, :in).add($center, :in)
    !! {
        my ($sin, $cos) = sin($angle), cos($angle);
        my @axii = <x y z>.grep: {$_ ne $axis};
        my %result;
        %result{@axii[0]} = self."@axii[0]"() * $cos - self."@axii[1]"() * $sin;
        %result{@axii[1]} = self."@axii[0]"() * $sin + self."@axii[1]"() * $cos;
        %result{$axis} = self."$axis"();
        self.v3d(
            %result<x>,
            %result<y>,
            %result<z>,
            :$in
        );
    }();
}



multi method rotate (
    Pray::Geometry::Vector3D $axis,
    $angle,
    Pray::Geometry::Vector3D :$center,
    :$in
) {
    $center ??
        self.subtract($center, :$in).rotate($axis, $angle, :in).add($center, :in)
    !! {
        my $cos = cos $angle;
        self.scale($cos, :$in).add(
            $axis.cross(self).scale(sin($angle), :in), :in
        ).add(
            $axis.scale( $axis.dot(self) * (1-$cos) ), :in
        );
    }();
}



method transform (Pray::Geometry::Matrix3D $m, :$in) {
    my $v := $m.values;
    self.v3d(
        $!x*$v[0][0] + $!y*$v[0][1] + $!z*$v[0][2] + $v[0][3],
        $!x*$v[1][0] + $!y*$v[1][1] + $!z*$v[1][2] + $v[1][3],
        $!x*$v[2][0] + $!y*$v[2][1] + $!z*$v[2][2] + $v[2][3],
        :$in
    )
}



