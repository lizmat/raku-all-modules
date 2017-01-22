# Exercise all scaling with all interpolation modes and ensure that
# at least, something comes back.

use GD::Raw;
use lib <t>;
use gdtest;
use Test;

constant X = 100;
constant Y = 100;

constant NX = 20;
constant NY = 20;

plan 160;

my ($major, $minor);

sub {
    $major = gdMajorVersion();
    $minor = gdMajorVersion();
    CATCH { skip-rest("too old libgd"); exit; }
}();
skip-rest "too old libgd" if $major == 2 and $minor < 2;

loop (my $method = +GD_BELL; $method <= +GD_TRIANGLE; $method++) { # GD_WEIGHTED4 is unsupported.

    my @im = (
        gdImageCreateTrueColor(X, Y),
        gdImageCreatePalette(X, Y));

    for @im -> $i {
        gdImageFilledRectangle($i, 0, 0, X-1, Y-1,
                               gdImageColorExactAlpha($i, 255, 255, 255, 0));

        gdImageSetInterpolationMethod($i, $method);
        is $i.interpolation_id, $method, "interpolation method $method set";

        my $result = gdImageScale($i, NX, NY)
            or die;
        isnt $result, $i, "not same image afte rscale";
        is NX, $result.sx, "scaled to correct x";
        is NY, $result.sy, "scaled to correct y";

        gdImageDestroy($result);
        gdImageDestroy($i);
    }
}
