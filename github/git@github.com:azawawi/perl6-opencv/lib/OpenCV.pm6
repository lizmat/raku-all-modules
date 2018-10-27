
use v6;

# Re-export all OpenCV module exported symbols
sub EXPORT {

  # Re-export symbols
  need OpenCV::Highgui;
  my %exports;
  for OpenCV::Highgui::EXPORT::DEFAULT::.kv -> $k, $v {
    %exports{$k} = $v;
  }

  # Re-export symbols
  need OpenCV::Photo;
  for OpenCV::Photo::EXPORT::DEFAULT::.kv -> $k, $v {
    %exports{$k} = $v;
  }

  return %exports;
}

unit module OpenCV;

use OpenCV::Mat;
