

use v6;

unit class Build;

method build($workdir) {
    if $*DISTRO.is-win {
      # On windows, let us install the bundled DLL version, module installer
      # will copy the DLL for us.
      say "Precompiled bundled OpenCV DLL will be installed";

      # Success
      return 1;
    }

    # on Unix, let us try to make it
    my $makefiledir = "$workdir/src";
    my $destdir = "$workdir/resources";
    $destdir.IO.mkdir;

    # Create empty resources files for all platforms so that package managers
    # do not complain
    for <dll dylib so> -> $ext {
      "$destdir/libopencv-perl6.$ext".IO.spurt("");
    }

    my @libs = <opencv_highgui opencv_core opencv_imgproc opencv_ml
      opencv_video opencv_features2d opencv_calib3d opencv_objdetect
      opencv_contrib opencv_legacy opencv_stitching opencv_photo>;
    my $libs = @libs.map( { "-l$_" } ).join(' ');
    my $libname = sprintf($*VM.config<dll>, "opencv-perl6");
    if $*DISTRO.name eq "macosx" {
      shell("g++ -Wall -shared -fPIC -I/usr/local/include -L/usr/local/lib -o $destdir/$libname src/libopencv-perl6.cpp $libs");
    } else {
      shell("g++ -Wall -shared -fPIC -o $destdir/$libname src/libopencv-perl6.cpp $libs");
    }
}

# only needed for older versions of panda
method isa($what) {
    return True if $what.^name eq 'Panda::Builder';
    callsame;
}
