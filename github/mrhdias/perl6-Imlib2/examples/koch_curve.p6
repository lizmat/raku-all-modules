#!/usr/bin/env perl6

BEGIN { @*INC.push('../lib') };

my $x0 = 0;
my $y0 = 0;
my $direction360 = 0;

my $recursions = 6;
my $width = 600;
my $height = ($width/3).Int;

use Imlib2;

my $im = Imlib2.new();
my $newimage = $im.create_image($width, $height);
exit() unless $newimage;
$newimage.context_set();

$im.context_set_color(0x000000ff);

$im.image_draw_rectangle(
	location => (0, 0),
	size     => ($width, $height),
	fill     => True);
	
my $polygon = $im.polygon_new();
exit() unless $polygon;

init($width, $height);
begin(0, $height - 1);
kock_curve($width, $recursions);

$im.context_set_color(0xff0000ff);
$im.image_draw_polygon($polygon);

$polygon.free();

$im.image_set_format("png");
unlink("images/test_koch_curve.png") if "images/test_koch_curve.png".IO ~~ :e;
$im.save_image("images/test_koch_curve.png");

$im.free_image();

exit();

sub init($width, $height) {
  $x0 = $width / 2;
  $y0 = $height / 2;
}

sub begin($x, $y) {
	$polygon.add_point(($x0 = $x).Int, ($y0 = $y).Int);
}

sub from360($angle360) {
	return pi * $angle360/180;
}
 
sub right($angle360) {
	$direction360 -= $angle360;
}

sub left($angle360) {
	$direction360 += $angle360;
}

sub forward($length) {
	my $x1 = $x0 + $length * cos(from360($direction360));
	my $y1 = $y0 + $length * sin(from360($direction360));
	$polygon.add_point(($x0 = $x1).Int, ($y0 = $y1).Int);
}

sub kock_curve($length, $depth) {
	if $depth == 0 {
		forward($length);
	} else {
		kock_curve($length/3, $depth - 1);
		right(60);
		kock_curve($length/3, $depth - 1);
		left(120);
		kock_curve($length/3, $depth - 1);
		right(60);
		kock_curve($length/3, $depth - 1);
	}
}

