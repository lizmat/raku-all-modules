use v6;

unit module OpenCV::NativeCall:ver<0.0.2>:auth<github:azawawi>;

use NativeCall;

# Find our compiled library.
sub library {
    my $lib-name = sprintf($*VM.config<dll>, "opencv-perl6");
    return ~(%?RESOURCES{$lib-name});
}

# 'is native(&library)' is needed so it will call the function and resolve the
# library at compile time, while we need it to happen at runtime (because
# this library is installed *after* being compiled).

sub cv_mat_rows(Pointer $img)
  returns uint32
  is native(&library)
  is export
  { * }

sub cv_mat_cols(Pointer $img)
  returns uint32
  is native(&library)
  is export
  { * }

sub cv_mat_data(Pointer $img)
  returns Pointer
  is native(&library)
  is export
  { * }

sub cv_mat_clone(Pointer $img)
  returns Pointer
  is native(&library)
  is export
  { * }

sub cv_highgui_imread(Str $filename, int32 $flags)
  returns Pointer
  is native(&library)
  is export
  { * }

#TODO implement Pointer params
sub cv_highgui_imwrite(Str $filename, Pointer $img)
  returns uint32 
  is native(&library)
  is export
  { * }

sub cv_highgui_imshow(Str $filename, Pointer $mat)
  is native(&library)
  is export
  { * }

sub cv_highgui_namedWindow(Str $winname, uint32 $flags)
  is native(&library)
  is export
  { * }

sub cv_highgui_moveWindow(Str $winname, uint32 $x, uint32 $y)
  is native(&library)
  is export
  { * }

sub cv_highgui_resizeWindow(Str $winname, uint32 $width, uint32 $height)
  is native(&library)
  is export
  { * }

sub cv_highgui_waitKey(uint32 $delay)
  returns int32
  is native(&library)
  is export
  { * }

sub cv_highgui_destroyWindow(Str $winname)
  is native(&library)
  is export
  { * }

sub cv_highgui_destroyAllWindows
  is native(&library)
  is export
  { * }

sub cv_highgui_createTrackbar(Str $trackbarname, Str $winname, uint32 $value,
    uint32 $count, &onChange (int32, OpaquePointer))
  is native(&library)
  returns uint32
  is export
  { * }

sub cv_photo_fastNlMeansDenoisingColored(
    Pointer $src,
    Pointer $dst,
    uint32 $h, 
    uint32 $hColor,
    uint32 $templateWindowSize,
    uint32 $searchWindowSize
  )
  returns int32
  is export
  is native(&library)
  { * }

sub cv_highgui_rectangle(
    Pointer $img,
    uint32 $x1, uint32 $y1, uint32 $x2, uint32 $y2,
    uint32 $b, uint32 $g, uint32 $r,
    uint32 $thickness,
    uint32 $lineType,
    uint32 $shift
  )
  is export
  is native(&library)
  { * }

sub cv_highgui_circle(
    Pointer $img,
    uint32 $cx, uint32 $cy, uint32 $radius,
    uint32 $b, uint32 $g, uint32 $r,
    uint32 $thickness,
    uint32 $lineType,
    uint32 $shift
  )
  is export
  is native(&library)
  { * }
