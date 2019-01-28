use v6;
use NativeCall;

use N::NativeLib;
use GdkScreen;

#-------------------------------------------------------------------------------
class N-GdkDisplay
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gdk/gdkscreen.h
class GdkDisplay:auth<github:MARTIMM> {

  #-----------------------------------------------------------------------------
  sub gdk_display_warp_pointer (
      N-GdkDisplay $display, N-GdkScreen $screen, int32 $x, int32 $y
    ) is native(&gdk-lib)
      is export
      { * }

  #-----------------------------------------------------------------------------

  # = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
  has N-GdkDisplay $!gdk-display;

  #-----------------------------------------------------------------------------
  submethod BUILD (  ) {
    $!gdk-display;
  }

  #-----------------------------------------------------------------------------
  method CALL-ME ( --> N-GdkDisplay ) {
    $!gdk-display
  }
}
