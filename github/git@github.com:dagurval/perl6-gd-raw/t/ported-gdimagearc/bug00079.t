use GD::Raw;
use lib <t>;
use gdtest;
use Test;

plan 1;

sub MAIN
{
    my $im = gdImageCreateTrueColor(300, 300);
    gdImageFilledRectangle($im, 0,0, 299,299, 0xFFFFFF);

    gdImageSetAntiAliased($im, 0x000000);
    gdImageArc($im, 300, 300, 600,600, 0, 360, gdAntiAliased);

    my $path = "t/ported-gdimagearc/bug00079_exp.png";
    ok gdAssertImageEqualsToFile($path, $im);
    gdImageDestroy($im);
}
