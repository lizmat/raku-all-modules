use v6;
use NativeCall;

use GTK::Glade::X;
use GTK::V3::N::NativeLib;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/gmain.h
unit class GTK::V3::Glib::GMain:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
#`{{
sub g_idle_add ( &Handler ( OpaquePointer $h_data), OpaquePointer $data )
  returns int32
  is native(&glib-lib)
  is export
  { * }
}}

# GMainContext is an opaque pointer
sub g_main_context_invoke (
  OpaquePointer $context,
  &sourceFunction ( OpaquePointer $data_h is rw --> Bool ),
  OpaquePointer $data is rw
  ) is native(&gtk-lib)
    { * }

sub g_timeout_add (
  int32 $interval, &Handler ( OpaquePointer $h_data, --> int32 ),
  OpaquePointer $data
  ) returns int32
    is native(&gtk-lib)
    { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
method FALLBACK ( $native-sub is copy, |c ) {

  $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-');

  my Callable $s;
  try { $s = &::($native-sub); }

  CATCH {
    default {
      die X::Gui.new(
        :message("Could not find native sub '$native-sub\(...\)'")
      );
    }
  }

  &$s(|c)
}
