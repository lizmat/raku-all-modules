use v6;
use NativeCall;

use N::NativeLib;

#-------------------------------------------------------------------------------
class N-GdkWindow:auth<github:MARTIMM>
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gdk/gdkwindow.h
class GdkWindow:auth<github:MARTIMM> {

  #-----------------------------------------------------------------------------
  enum GdkWindowType <
    GDK_WINDOW_ROOT
    GDK_WINDOW_TOPLEVEL
    GDK_WINDOW_CHILD
    GDK_WINDOW_TEMP
    GDK_WINDOW_FOREIGN
    GDK_WINDOW_OFFSCREEN
    GDK_WINDOW_SUBSURFACE
  >;

  #-----------------------------------------------------------------------------
  sub gdk_window_get_origin (
    N-GdkWindow $window, int32 $x is rw, int32 $y is rw
    ) returns int32
      is native(&gdk-lib)
      is export
      { * }

  sub gdk_window_destroy ( N-GdkWindow $window )
    is native(&gdk-lib)
    is export
    { * }

  sub gdk_window_get_window_type ( N-GdkWindow $window )
    returns int32 #GdkWindowType
    is native(&gdk-lib)
    is export
    { * }

  # = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
  has N-GdkWindow $!gdk-window;

  #-----------------------------------------------------------------------------
  submethod BUILD ( GdkWindow :$parent ) {
    $!gdk-window = $parent() if ?$parent;
  }

  #-----------------------------------------------------------------------------
  submethod DESTROY ( ) {

    if ?$!gdk-window {
      gdk_window_destroy($!gdk-window);
      $!gdk-window = N-GdkWindow;
    }
  }

  #-----------------------------------------------------------------------------
  method CALL-ME ( --> N-GdkWindow ) {
    $!gdk-window
  }
}
