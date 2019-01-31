use v6;
use NativeCall;

use GTK::Glade::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Gdk::GdkScreen;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gdk/gdkscreen.h
unit class GTK::V3::Gdk::GdkDisplay:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
class N-GdkDisplay
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
sub gdk_display_warp_pointer (
    N-GdkDisplay $display, N-GdkScreen $screen, int32 $x, int32 $y
  ) is native(&gdk-lib)
    { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
has N-GdkDisplay $!gdk-display;

#-------------------------------------------------------------------------------
submethod BUILD (  ) {
  $!gdk-display;
}

#-------------------------------------------------------------------------------
method CALL-ME ( --> N-GdkDisplay ) {
  $!gdk-display
}

#-------------------------------------------------------------------------------
method FALLBACK ( $native-sub is copy, |c ) {

  $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-');

  my Callable $s;
  try { $s = &::($native-sub); }
  try { $s = &::("gdk_display_$native-sub"); } unless ?$s;

  CATCH {
    default {
      when X::AdHoc {
        die X::Gui.new(:message(.message));
      }

      when X::TypeCheck::Argument {
        die X::Gui.new(:message(.message));
      }

      die X::Gui.new(
        :message("Could not find native sub '$native-sub\(...\)'")
      );
    }
  }

  &$s( $!gdk-display, |c)
}
