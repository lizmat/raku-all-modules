use GD::Raw;
use lib <t>;
use gdtest;
use Test;

plan 13;

my $path = "t/ported-gdimagerotate/remirh128.jpg";
my $file_exp = "t/ported-gdimagerotate/bug00067";

my $fp = fopen($path, "rb")
    or die "fopen";
LEAVE { fclose($fp) if $fp }

my $im = gdImageCreateFromJpeg($fp)
    or die "gdImageCreateFromJpeg";
LEAVE { gdImageDestroy($im) if $im }

my $color = gdImageColorAllocate($im, 0, 0, 0);
die "allocating color failed"
    unless $color >= 0;

todo "comparison of rotated image sizes not right", 13;
# using scientific notation as a workaround in Rakudo
loop (my $angle = 0e0; $angle <= 180e0; $angle += 15e0) {
    my $exp = gdImageRotateInterpolated($im, $angle, $color);
    die "rotating image failed for angle $angle"
        unless $exp;

    ok gdAssertImageEqualsToFile($file_exp ~ "_" ~ $angle ~ "_exp.png", $exp), "rotated $angle";
    gdImageDestroy($exp);
}

