
use v6;

unit module OpenCV::Highgui:ver<0.0.2>:auth<github:azawawi>;

use NativeCall;
use OpenCV::NativeCall;
use OpenCV::Mat;

# http://docs.opencv.org/2.4.11/modules/highgui/doc/reading_and_writing_images_and_video.html?highlight=imread#cv2.imread
sub imread(Str $filename, Int $flags = 1) returns OpenCV::Mat is export {
  my Pointer $native_obj = cv_highgui_imread($filename, $flags);
  return OpenCV::Mat.new( native_obj => $native_obj );
}

# http://docs.opencv.org/2.4.11/modules/highgui/doc/reading_and_writing_images_and_video.html?highlight=imwrite#cv2.imwrite
sub imwrite(Str $filename, OpenCV::Mat $img) returns Bool is export {
  return cv_highgui_imwrite($filename, $img.native_obj) > 0;
}

sub imshow(Str $winname, OpenCV::Mat $mat) is export {
  cv_highgui_imshow($winname, $mat.native_obj);
}

sub namedWindow(Str $winname, Int $flags = 1) is export {
  cv_highgui_namedWindow($winname, $flags);
}

sub moveWindow(Str $winname, Int $x, Int $y) is export {
  cv_highgui_moveWindow($winname, $x, $y);
}

sub resizeWindow(Str $winname, Int $width, Int $height) is export {
  cv_highgui_resizeWindow($winname, $width, $height);
}

sub waitKey(Int $delay = 0) is export {
  cv_highgui_waitKey($delay);
}

sub destroyWindow(Str $winname) is export {
  cv_highgui_destroyWindow($winname);
}

sub destroyAllWindows is export {
  cv_highgui_destroyAllWindows;
}

sub createTrackbar(Str $trackbarname, Str $winname, Int $value, Int $count,
  &onChange:(uint32, OpaquePointer)) returns Int is export
{
  return cv_highgui_createTrackbar($trackbarname, $winname, $value, $count, &onChange);
}

sub rectangle(
  OpenCV::Mat $mat,
  Int $x1, Int $y1, Int $x2, Int $y2,
  Int $b, Int $g, Int $r,
  Int $thickness = 1,
  Int $lineType  = 8,
  Int $shift     = 0
) is export
{
  cv_highgui_rectangle($mat.native_obj, $x1, $y1, $x2, $y2, $b, $g, $r, $thickness,
    $lineType, $shift);
}

sub circle(
  OpenCV::Mat $mat,
  Int $cx, Int $cy, Int $radius,
  Int $b, Int $g, Int $r,
  Int $thickness = 1,
  Int $lineType  = 8,
  Int $shift     = 0
) is export
{
  cv_highgui_circle($mat.native_obj, $cx, $cy, $radius, $b, $g, $r, $thickness,
    $lineType, $shift);
}
