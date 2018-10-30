
use v6;

unit class Graphics::PLplot;

use NativeCall;
use Graphics::PLplot::Raw;

has Str $.device;
has Str $.file-name;

method begin {
    # Set output device
    plsdev($!device);

    # Set Output device and filename (if set)
    plsfnam($!file-name) if $!file-name;

    # Initialize plplot
    plinit;
}

method environment(:$x-range, :$y-range, :$just, :$axis) {
    plenv($x-range[0].Num, $x-range[1].Num, $y-range[0].Num, $y-range[1].Num,
        $just, $axis);
}

method label(Str :$x-axis, Str :$y-axis, Str :$title) {
    pllab($x-axis, $y-axis, $title);
}

# Plot the data
method line(@points) {
    my $xc   = CArray[num64].new;
    my $yc   = CArray[num64].new;
    my $size = @points.elems;
    for 0..^$size -> $i {
        $xc[$i] = @points[$i][0];
        $yc[$i] = @points[$i][1];
    }

    plline($size, $xc, $yc);
}

=begin pod
=head2 orientation

Sets integer plot orientation parameter which (0 for landscape, 1 for portrait,
etc.). The value is multiplied by 90 degrees to get the angle.

=end pod

method orientation(Int $orientation) {
    plsori($orientation)
}

method arc(:$center, :$semi-major, :$semi-minor, :$angle1, :$angle2, :$rotate,
    Bool :$fill)
{
    plarc($center[0].Num, $center[1].Num, $semi-major.Num, $semi-minor.Num,
        $angle1.Num, $angle2.Num, $rotate.Num, $fill);
}

=begin pod

=head2 color-index0

Sets the color index for cmap0

0 	black (default background)
1 	red (default foreground)
2 	yellow
3 	green
4 	aquamarine
5 	pink
6 	wheat
7 	grey
8 	brown
9 	blue
10 	BlueViolet
11 	cyan
12 	turquoise
13 	magenta
14 	salmon
15 	white

=end pod

method color-index0($color) {
    plcol0($color);
}

=begin pod

=head2 join

Draw a line between two points

=end pod

method join($x1, $y1, $x2, $y2) {
    pljoin($x1.Num, $y1.Num, $x2.Num, $y2.Num);
}

=begin pod

=head2 text

Write text inside the viewport

=end pod
method text(:@point, :@inclination, :$just, :$text) {
    plptex(@point[0].Num, @point[1].Num, @inclination[0].Num,
        @inclination[1].Num, $just.Num, $text);
}

=begin pod

=head2 text

Write text relative to viewport boundaries

=end pod

method text-viewport(Str :$side,  :$disp, :$pos, :$just, Str :$text) {
    plmtex($side, $disp.Num, $pos.Num, $just.Num, $text);
}

method end {
    # Close PLplot library
    plend;
}

method version returns Str {
    my $ver = CArray[int8].new;
    $ver[79] = 0;
    plgver($ver);
    my $version = '';
    for 0..$ver.elems -> $i {
        last if $ver[$i] == 0;
        $version ~= $ver[$i].chr;
    }
    return $version
}

method character-size(:$default, :$scale) {
    plschr($default.Num, $scale.Num);
}

method font(Int $font) {
    plfont($font);
}

method subpage(Int $sub-page) {
    pladv($sub-page);
}

method pen-width($width) {
    plwidth($width.Num)
}

method subpage-viewport($xmin, $xmax, $ymin, $ymax) {
    plvpor($xmin.Num, $xmax.Num, $ymin.Num, $ymax.Num);
}

method window($xmin, $xmax, $ymin, $ymax) {
    plwind($xmin.Num, $xmax.Num, $ymin.Num, $ymax.Num);
}

method box(Str $xopt, $xtick, $nxsub, $yopt, $ytick, $nysub) {
    plbox($xopt, $xtick.Num, $nxsub, $yopt, $ytick.Num, $nysub);
}

method new-page {
    plbop
}

method clear-or-eject-page {
    pleop
}

method number-of-subpages($nx, $ny) {
    plssub($nx, $ny)
}

method hls-to-rgb($hue, $lightness, $saturation) {
    my (num64 $r, num64 $g, num64 $b);
    plhlsrgb($hue.Num, $lightness.Num, $saturation.Num, $r, $g, $b);
    return $r.Rat, $g.Rat, $b.Rat;
}

method color-index0-rgb($index) {
    my (int32 $red, int32 $green, int32 $blue);
    plgcol0($index, $red, $green, $blue);
    return ($red.Int, $green.Int, $blue.Int);
}

method set-cmap0-rgb-colors(@rgb) {
    my $red = CArray[int32].new;
    my $green = CArray[int32].new;
    my $blue = CArray[int32].new;

    for ^@rgb.elems -> $i {
        $red[$i] = @rgb[$i][0];
        $green[$i] = @rgb[$i][1];
        $blue[$i] = @rgb[$i][2];
    }

    plscmap0($red, $green, $blue, @rgb.elems);
}
