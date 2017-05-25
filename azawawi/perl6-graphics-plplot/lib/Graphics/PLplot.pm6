
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
    plenv( $x-range[0].Num, $x-range[1].Num, $y-range[0].Num, $y-range[1].Num,
        $just, $axis );
}

method label(Str :$x-axis, Str :$y-axis, Str :$title) {
    pllab( $x-axis, $y-axis, $title );
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

    plline( $size, $xc, $yc );
}

method end {
    # Close PLplot library
    plend;
}
