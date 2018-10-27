#!/usr/bin/env perl6

use v6;
use lib 'lib';
use NativeCall;
use OpenCV;

# Read image data
my $filename = "examples/images/aero1.jpg";
my OpenCV::Mat $img = imread($filename);
my $data = $img.data;
die "Could not read $filename" unless $data;

# Print dimensions
say "Matrix cols = " ~ $img.cols;
say "Matrix rows = " ~ $img.rows;

# Read grayscale version
my OpenCV::Mat $grayscale_img = imread($filename, 0);

# De-noise (i.e. remove noise) in a new cloned image
my OpenCV::Mat $denoised_img = $img.clone;
fastNlMeansDenoisingColored($img, $denoised_img, 10, 10, 7, 21);

# Show original image
namedWindow("Original", 1);
imshow("Original", $img);

# Show grayscale version
namedWindow("Grayscale", 0);
moveWindow("Grayscale", 100, 100);
resizeWindow("Grayscale", 320, 240);
imshow("Grayscale", $grayscale_img);

my Int $slider_value = 5;
sub onChange(uint32 $value, OpaquePointer $) {
  $slider_value = $value;
}
createTrackbar("Value", "Original", $slider_value, 100, &onChange);

# Show denoised image
namedWindow("Denoised", 1);
imshow("Denoised", $denoised_img);

imwrite("denoised.png", $denoised_img);

# Wait for ESC from the user
my Int $last_slider_value = -1;
while True {
  if $slider_value != $last_slider_value {
    my $percentage = $slider_value / 100.0;
    resizeWindow("Grayscale", Int(320 * $percentage), Int(240 * $percentage));
    imshow("Grayscale", $grayscale_img);

    $last_slider_value = $slider_value;
  }

  last if waitKey(1) == 27;
}

destroyAllWindows;
