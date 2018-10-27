use GD::Raw;
use lib <t>;
use gdtest;
use Test;

plan 1738;

constant WIDTH = 12;
constant BLOCK_SIZE = 4;

constant expected_upperleft = [
	[0x000000, 0x040404, 0x080808],
	[0x303030, 0x343434, 0x383838],
	[0x606060, 0x646464, 0x686868]
];

constant expected_average = [
	[0x131313, 0x171717, 0x1b1b1b],
	[0x434343, 0x474747, 0x4b4b4b],
	[0x737373, 0x777777, 0x7b7b7b]
];

sub SETUP_PIXELS($im) {
    my $x;
    my $y;
    my $i = 0;
    loop ($y = 0; $y < $im.sy; $y++) {
        loop ($x = 0; $x < $im.sx; $x++) {
            my $p = gdImageColorResolve($im, $i, $i, $i);
            gdImageSetPixel($im, $x, $y, $p);
            $i++;
        }
    }
}

sub CHECK_PIXELS($im, $expected)
{
    my int32 ($x, $y);
    loop ($y = 0; $y < $im.sy; $y++) {
        loop ($x = 0; $x < $im.sx; $x++) {
            my int32 $p = gdImageGetPixel($im, $x, $y);
            my $exp_y = ($y / BLOCK_SIZE).floor;
            my $exp_x = ($x / BLOCK_SIZE).floor;
            my int32 $r = ($expected[$exp_y][$exp_x] +>16) +& 0xFF;
            my int32 $g = ($expected[$exp_y][$exp_x] +> 8) +& 0xFF;
            my int32 $b = $expected[$exp_y][$exp_x] +& 0xFF;
            is gdImageRed($im, $p), $r,"Red is as expected";
            is gdImageGreen($im, $p), $g, "Green is as expected";
            is gdImageBlue($im, $p), $b, "Blue is as expected";
        }															\
    }																\
}

sub testPixelate(gdImagePtr $im)
{
	is gdImagePixelate($im, -1, GD_PIXELATE_UPPERLEFT), 0;
	is gdImagePixelate($im, 1, GD_PIXELATE_UPPERLEFT), 1;
	is gdImagePixelate($im, 2, -1), 0;

	SETUP_PIXELS($im);
	ok gdImagePixelate($im, BLOCK_SIZE, GD_PIXELATE_UPPERLEFT);
	CHECK_PIXELS($im, expected_upperleft);

	SETUP_PIXELS($im);
	ok gdImagePixelate($im, BLOCK_SIZE, GD_PIXELATE_AVERAGE);
	CHECK_PIXELS($im, expected_average);
}

sub MAIN()
{
	my $im = gdImageCreate(WIDTH, WIDTH);
    testPixelate($im);
	gdImageDestroy($im);

	$im = gdImageCreateTrueColor(WIDTH, WIDTH);
	testPixelate($im);
	gdImageDestroy($im);

	return 0;
}
