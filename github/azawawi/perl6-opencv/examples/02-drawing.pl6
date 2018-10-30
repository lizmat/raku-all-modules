#!/usr/bin/env perl6

use v6;
use lib 'lib';
use OpenCV;

my $filename        = "examples/images/camelia-logo.png";
my OpenCV::Mat $img = imread( $filename );
my $data            = $img.data;
die "Could not read $filename" unless $data;

# Print dimensions
my ($width, $height) = ($img.cols, $img.rows);
say "Camelia width = "  ~ $width;
say "Camelia height = " ~ $height;


namedWindow("Camelia", 1);

while True {

  # Random starting coordinates
  my $x = (0..$width-1).pick;
  my $y = (0..$height-1).pick;

  # Draw a randomly colored and sized rectangle
  rectangle(
    $img,
    $x, $y,
    $x+(5..10).pick,
    $y+(5..10).pick,
    (0..255).pick, (0..255).pick, (0..255).pick,
    -1);

  # Draw a randomly colored and sized circle
  $x = (0..$width-1).pick;
  $y = (0..$height-1).pick;
  circle(
    $img,
    $x, $y, (5..10).pick,
    (0..255).pick, (0..255).pick, (0..255).pick,
    -1);
  imshow("Camelia", $img);

  # Wait x milliseconds for an ESC to exit this loop
  last if waitKey(50) == 27;
}
