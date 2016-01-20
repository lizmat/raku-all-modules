#!/usr/bin/env perl6

use v6;
my $OPENCV_LIB="opencv_calib3d2411.lib opencv_contrib2411.lib opencv_core2411.lib opencv_features2d2411.lib opencv_flann2411.lib opencv_gpu2411.lib opencv_highgui2411.lib opencv_imgproc2411.lib  opencv_legacy2411.lib opencv_ml2411.lib opencv_nonfree2411.lib opencv_objdetect2411.lib opencv_ocl2411.lib opencv_photo2411.lib opencv_stitching2411.lib opencv_superres2411.lib opencv_ts2411.lib opencv_video2411.lib opencv_videostab2411.lib IlmImf.lib libjasper.lib libjpeg.lib libpng.lib libtiff.lib zlib.lib";
my $OPENCV_BUILD="D:/downloads/tools/Graphics/OpenCV/opencv-2.4.11/opencv/build";
my $OPENCV_INCLUDE="$OPENCV_BUILD/include";
my $OPENCV_LIBPATH = "$OPENCV_BUILD/x64/vc12/staticlib";

my $dest_folder = "../resources";
$dest_folder.IO.mkdir unless $dest_folder.IO ~~ :e;

my $SYSTEM_LIB = "user32.lib Gdi32.lib advapi32.lib";

# Patch environment variables for Microsoft C++ compiler to work
%*ENV<Path>   ~= ';C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\amd64';
%*ENV<INCLUDE> = 'C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\INCLUDE';
%*ENV<LIB>     = 'C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\LIB\amd64;C:\Program Files (x86)\Windows Kits\8.1\lib\winv6.3\um\x64;';

my $cmd        = qq{cl.exe /EHsc -I"$OPENCV_INCLUDE" /nologo /MT /Ox /GL /DNDEBUG  /DWIN32 /DAO_ASSUME_WINDOWS98 libopencv-perl6.cpp /LD /DLL /link /LIBPATH:"$OPENCV_LIBPATH" $SYSTEM_LIB $OPENCV_LIB /OUT:../resources/libopencv-perl6.dll};
say $cmd;
shell($cmd);
