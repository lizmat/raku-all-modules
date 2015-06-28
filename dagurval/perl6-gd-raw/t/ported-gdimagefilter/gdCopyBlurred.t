BEGIN { @*INC.unshift('t') }
use GD::Raw;
use gdtest;
use Test;

plan 29;

constant WIDTH = 300;
constant HEIGHT = 200;
constant LX = (WIDTH/2).round; # Line X
constant LY = (HEIGHT/2).round; # Line Y
constant HT = 3; # Half of line-thickness

constant CLOSE_ENOUGH = 0;
constant PIXEL_CLOSE_ENOUGH = 0;


sub save($im, $filename) { }

# Test gdImageScale() with bicubic interpolation on a simple
# all-white image.
sub mkwhite(int32 $x, int32 $y)
{
	my $im = gdImageCreateTrueColor($x, $y);
	gdImageFilledRectangle($im, 0, 0, $x - 1, $y - 1,
                           gdImageColorExactAlpha($im, 255, 255, 255, 0));

    die unless $im;

    gdImageSetInterpolationMethod($im, GD_BICUBIC); # FP interp'n

    return $im;
}


# Fill with almost-black.
sub mkblack(gdImagePtr $ptr)
{
    gdImageFilledRectangle($ptr, 0, 0, $ptr.sx - 1, $ptr.sy - 1,
                           gdImageColorExactAlpha($ptr, 2, 2, 2, 0));
}


sub mkcross() {

    my $im = mkwhite(WIDTH, HEIGHT);
    my $fg = gdImageColorAllocate($im, 0, 0, 0);

    loop (my $n = -HT; $n < HT; $n++) {
        gdImageLine($im, LX - $n, 0, LX - $n, HEIGHT - 1, $fg);
        gdImageLine($im, 0, LY - $n, WIDTH - 1, LY - $n, $fg);
    }

    return $im;
}

sub blurblank(gdImagePtr $im, int32 $radius, num64 $sigma) {
    my $result = gdImageCopyGaussianBlurred($im, $radius, $sigma)
        or die;

    ok gdMaxPixelDiff($im, $result) <= CLOSE_ENOUGH;
    gdImageDestroy $result;
}

sub do_test()
{
	my $im = mkwhite(WIDTH, HEIGHT);
    LEAVE gdImageDestroy($im) if $im;
    my $imref = mkwhite(WIDTH, HEIGHT);
    LEAVE gdImageDestroy($imref) if $imref;

    # Blur a plain white image to various radii and ensure they're
    # still similar enough.
    blurblank($im, 1, 0e0); # Using scientific double to work around a MoarVM bug
    blurblank($im, 2, 0e0);
    blurblank($im, 4, 0e0);
    blurblank($im, 8, 0e0);
    blurblank($im, 16, 0e0);

    # Ditto a black image.
    mkblack($im);
    ok (gdMaxPixelDiff($im, $imref) >= 240); # Leaves a little wiggle room

    blurblank($im, 1, 0e0);
    blurblank($im, 2, 0e0);
    blurblank($im, 4, 0e0);
    blurblank($im, 8, 0e0);
    blurblank($im, 16, 0e0);
}

# Ensure that RGB values are equal, then return r (which is therefore
# the whiteness.)
sub getwhite(gdImagePtr $im, int32 $x, int32 $y)
{
    my $px = gdImageGetPixel($im, $x, $y);
    my $r = gdImageRed($im, $px);
    my $g = gdImageGreen($im, $px);
    my $b = gdImageBlue($im, $px);

    die unless $r == $g;
    die unless $r == $b;

    return $r;
}

sub whitecmp(gdImagePtr $im1, gdImagePtr $im2, int32 $x, int32 $y) {

    my $w1 = getwhite($im1, $x, $y);
    my $w2 = getwhite($im2, $x, $y);

    return abs($w1 - $w2);
}

sub do_crosstest()
{
    my $im = mkcross() or die;
    LEAVE gdImageDestroy $im if $im;
    constant RADIUS = 16;

    save($im, "cross.png");

    my $blurred = gdImageCopyGaussianBlurred($im, RADIUS, 0e0)
        or die;
    LEAVE gdImageDestroy $blurred if $blurred;
    save($blurred, "blurredcross.png");

    # These spots shouldn't be affected.
    ok whitecmp($im, $blurred, 5, 5) <= PIXEL_CLOSE_ENOUGH;
    ok whitecmp($im, $blurred, WIDTH  -5, 5) <= PIXEL_CLOSE_ENOUGH;
    ok whitecmp($im, $blurred, 5, HEIGHT - 5) <= PIXEL_CLOSE_ENOUGH;
    ok whitecmp($im, $blurred, WIDTH - 5, HEIGHT - 5) <= PIXEL_CLOSE_ENOUGH;

    # Ditto these, right in the corners
    ok whitecmp($im, $blurred, 0, 0) <= PIXEL_CLOSE_ENOUGH;
    ok whitecmp($im, $blurred, WIDTH - 1, 0) <= PIXEL_CLOSE_ENOUGH;
    ok whitecmp($im, $blurred, 0, HEIGHT - 1) <= PIXEL_CLOSE_ENOUGH;
    ok whitecmp($im, $blurred, WIDTH - 1, HEIGHT - 1) <= PIXEL_CLOSE_ENOUGH;

    # Now, poking let's poke around the blurred lines.

    # Vertical line gets darker when approached from the left.
    ok getwhite($blurred, 1, 1) > getwhite($blurred, LX - (HT - 1), 1);
    ok getwhite($blurred, LX - 2, 1) > getwhite($blurred, LX - 1, 1);

    # ...and lighter when moving away to the right.
    ok getwhite($blurred, LX + 2, 1) >= getwhite($blurred, LX + 1, 1);
    ok getwhite($blurred, LX + 3, 1) >= getwhite($blurred, LX + 2, 1);
    ok getwhite($blurred, WIDTH - 1, 1) > getwhite($blurred, LX + 1, 1);

    # And the same way, vertically
    ok getwhite($blurred, 1, 1) > getwhite($blurred, 1, LY - (HT - 1));
    ok getwhite($blurred, 1, LY - (HT - 1)) > getwhite($blurred, 1, LY - (HT - 2));

    ok getwhite($blurred, 1, LY)     <= getwhite($blurred, 1, LY + 1);
    ok getwhite($blurred, 1, LY + 1) <  getwhite($blurred, 1, LY + 3);
    ok getwhite($blurred, 1, LY + 3) <  getwhite($blurred, 1, HEIGHT-1);
}

my $major;
my $minor;
sub {
    $major = gdMajorVersion();
    $minor = gdMajorVersion();
    CATCH { skip-rest("too old libgd"); exit; }
}();
skip-rest "too old libgd" if $major == 2 and $minor < 2;

do_test();
do_crosstest();
