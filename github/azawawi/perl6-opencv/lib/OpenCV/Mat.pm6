
use v6;

unit class OpenCV::Mat:ver<0.0.2>:auth<github:azawawi>;

use NativeCall;
use OpenCV::NativeCall;

has Pointer $.native_obj;

method rows returns Int {
  return cv_mat_rows($.native_obj);
}

method cols returns Int {
  return cv_mat_cols($.native_obj);
}

method data returns Pointer {
  return cv_mat_data($.native_obj);
}

method clone returns OpenCV::Mat {
  my $native_obj = cv_mat_clone($.native_obj);
  return OpenCV::Mat.new( native_obj => $native_obj );
}