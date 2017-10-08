use v6;
use GD::Raw;
use lib <t>;
use gdtest;
use Test;

plan 1;

my $path = "t/ported-gdimagerotate/php_bug_64898.png";
my $file-exp = "t/ported-gdimagerotate/php_bug_64898_exp.png";

my $fp = fopen($path, "rb")
    or die "opening $path failed";

my $im = gdImageCreateTrueColor(141, 200)
    or die "loading $path failed";

LEAVE { 
    fclose $fp if $fp;
    gdImageDestroy $im if $im;
}

gdImageFilledRectangle($im, 0, 0, 140, 199, 0x00ffffff);

my $exp = gdImageRotateInterpolated($im, 45e0, 0x0)
    or die "rotating image failed";
LEAVE gdImageDestroy $exp if $exp;

todo "image geometry comparison not right",1;
ok gdAssertImageEqualsToFile($file-exp, $exp), "comparing rotated image";
