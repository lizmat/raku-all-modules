use v6;
use NativeCall;

use N::NativeLib;

#-------------------------------------------------------------------------------
class N-GdkScreen
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gdk/gdkscreen.h
class GdkScreen:auth<github:MARTIMM> {

  #-----------------------------------------------------------------------------
  sub gdk_screen_get_default ( )
      returns N-GdkScreen
      is native(&gdk-lib)
      is export
      { * }

  #-----------------------------------------------------------------------------

  # = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
  has N-GdkScreen $!gdk-screen;

  #-----------------------------------------------------------------------------
  submethod BUILD (  ) {
    $!gdk-screen = gdk_screen_get_default();
  }

  #-----------------------------------------------------------------------------
  method CALL-ME ( --> N-GdkScreen ) {
    $!gdk-screen
  }
}
