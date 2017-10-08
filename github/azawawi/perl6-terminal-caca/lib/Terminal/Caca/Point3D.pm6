
use v6;

use Terminal::Caca::Point2D;

unit class Point3D;

has $.x is rw;
has $.y is rw;
has $.z is rw;

method rotate-x($angle) {
    my $radians   = $angle * pi / 180.0;
    my $sin-theta = sin($radians);
    my $cos-theta = cos($radians);
    my $rx        = $!x;
    my $ry        = $!y * $cos-theta - $!z * $sin-theta;
    my $rz        = $!y * $sin-theta + $!z * $cos-theta;
    return Point3D.new( x => $rx, y => $ry, z => $rz )
}

method rotate-y($angle) {
    my $radians   = $angle * pi / 180.0;
    my $sin-theta = sin($radians);
    my $cos-theta = cos($radians);
    my $rx        = $!x * $cos-theta - $!z * $sin-theta;
    my $ry        = $!y;
    my $rz        = $!x * $sin-theta + $!z * $cos-theta;
    return Point3D.new( x => $rx, y => $ry, z => $rz )
}

method rotate-z($angle) {
    my $radians   = $angle * pi / 180.0;
    my $sin-theta = sin($radians);
    my $cos-theta = cos($radians);
    my $rx        = $!x * $cos-theta - $!y * $sin-theta;
    my $ry        = $!x * $sin-theta + $!y * $cos-theta;
    my $rz        = $!z;
    return Point3D.new( x => $rx, y => $ry, z => $rz )
}

method to-point2d($D = 5) returns Point2D {
    my $px = $!x * $D / ( $D + $!z );
    my $py = $!y * $D / ( $D + $!z );
    Point2D.new( x => $px, y => $py )
}
