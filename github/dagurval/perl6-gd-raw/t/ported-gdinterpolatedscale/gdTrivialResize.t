use GD::Raw;
use lib <t>;
use gdtest;
use Test;

# Test gdImageScale() with bicubic interpolation on a simple
# all-white image.

plan 18;

sub mkwhite($x, $y)
{
	my $im = gdImageCreateTrueColor($x, $y);

	gdImageFilledRectangle($im, 0, 0, $x-1, $y-1,
                           gdImageColorExactAlpha($im, 255, 255, 255, 0));

    die unless $im;
    gdImageSetInterpolationMethod($im, +GD_BICUBIC); # FP interp'n
    is $im.interpolation_id, +GD_BICUBIC, "interpolation method set";

    return $im;
}


# Fill with almost-black.
sub mkblack(gdImagePtr $ptr)
{
    gdImageFilledRectangle($ptr, 0, 0, $ptr.sx - 1, $ptr.sy - 1,
                           gdImageColorExactAlpha($ptr, 2, 2, 2, 0));
}


constant CLOSE_ENOUGH = 15;

sub scaletest($x, $y, $nx, $ny)
{
	my $imref = mkwhite($x, $y);
    my $im = mkwhite($x, $y);

    my $tmp = gdImageScale($im, $nx, $ny);
    my $same = gdImageScale($tmp, $x, $y);

    # Test the result to insure that it's close enough to the
    # original.
    ok gdMaxPixelDiff($im, $same) < CLOSE_ENOUGH, "scaled close enough to original";

    # Modify the original and test for a change again.  (I.e. test
    # for accidentally shared memory.)
    mkblack($tmp);
    ok gdMaxPixelDiff($imref, $same) < CLOSE_ENOUGH, "no accidentally shared memory";

    gdImageDestroy($im);
    gdImageDestroy($tmp);
    gdImageDestroy($same);
}

sub do_test(uint32 $x, uint32 $y, $nx, $ny) {
	my gdImagePtr $im = mkwhite($x, $y);
    my gdImagePtr $imref = mkwhite($x, $y);

    my $same = gdImageScale($im, $x, $y);


    # Trivial resize should be a straight copy.
    isnt $same, $im, "is a copy";
    is gdMaxPixelDiff($im, $same), 0, "copy equals original";
    is gdMaxPixelDiff($imref, $same), 0, "copy equals image equal to original";

    # Ensure that modifying im doesn't modify same (i.e. see if we
    # can catch them accidentally sharing the same pixel buffer.)
    mkblack($im);
    is gdMaxPixelDiff($imref, $same), 0, "no accidentally shared pixel buffer";

    gdImageDestroy($same);
    gdImageDestroy($im);

    # Scale horizontally, vertically and both.
    scaletest($x, $y, $nx, $y);
    scaletest($x, $y, $x, $ny);
    scaletest($x, $y, $nx, $ny);
}

my ($major, $minor);

sub {
    $major = gdMajorVersion();
    $minor = gdMajorVersion();
    CATCH { skip-rest("too old libgd"); exit; }
}();
skip-rest "too old libgd" if $major == 2 and $minor < 2;

do_test(300, 300, 600, 600);
#do_test(3200, 2133, 640, 427); # Skipped. Takes forever.
