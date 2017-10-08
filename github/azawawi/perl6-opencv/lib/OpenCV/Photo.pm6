
use v6;

unit module OpenCV::Photo:ver<0.0.2>:auth<github:azawawi>;

use NativeCall;
use OpenCV::NativeCall;
use OpenCV::Mat;

sub fastNlMeansDenoisingColored(
    OpenCV::Mat $src,
    OpenCV::Mat $dst,
    Real $h = 3.0, 
    Real $hColor = 3.0,
    Int $templateWindowSize = 7,
    Int $searchWindowSize = 21
) is export {
    cv_photo_fastNlMeansDenoisingColored( $src.native_obj,$dst.native_obj, $h,
      $hColor, $templateWindowSize, $searchWindowSize);
}