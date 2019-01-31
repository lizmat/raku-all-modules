use v6;
use NativeCall;

use GTK::Glade::X;
use GTK::V3::N::NativeLib;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gdk/gdkscreen.h
unit class GTK::V3::Gdk::GdkScreen:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
class N-GdkScreen
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
sub gdk_screen_get_default ( )
  returns N-GdkScreen
  is native(&gdk-lib)
#    is export
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
has N-GdkScreen $!gdk-screen;

#-------------------------------------------------------------------------------
submethod BUILD (  ) {
  $!gdk-screen = gdk_screen_get_default();
}

#-------------------------------------------------------------------------------
method CALL-ME ( --> N-GdkScreen ) {
  $!gdk-screen
}

#-------------------------------------------------------------------------------
method FALLBACK ( $native-sub is copy, |c ) {

  $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-');

  my Callable $s;
  try { $s = &::($native-sub); }
  try { $s = &::("gdk_screen_$native-sub"); } unless ?$s;

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

  &$s( $!gdk-screen, |c)
}
