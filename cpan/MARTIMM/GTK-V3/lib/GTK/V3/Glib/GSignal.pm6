use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::N::N-GObject;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/gobject/gsignal.h
# /usr/include/glib-2.0/gobject/gobject.h
# https://developer.gnome.org/gobject/stable/gobject-Signals.html
unit class GTK::V3::Glib::GSignal:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
enum GConnectFlags is export (
  G_CONNECT_AFTER	        => 1,
  G_CONNECT_SWAPPED	      => 1 +< 1
);

#-------------------------------------------------------------------------------
# original handler signature:
#   &handler ( N-GObject $h_widget, OpaquePointer $h_data )
# widget is inserted when second call to method is made and data is only
# definable as an OpaquePointer so it can not give any data. This is also
# inserted in second call. See GtkWidget.
sub g_signal_connect_wd (
  N-GObject $widget, Str $signal,
  &handler ( N-GObject, OpaquePointer ), OpaquePointer
) {
  g_signal_connect_data_wd(
    $widget, $signal, &handler, OpaquePointer, Any, 0
  );
}

sub g_signal_connect_after_wd (
  N-GObject $widget, Str $signal,
  &handler ( N-GObject, OpaquePointer ), OpaquePointer
) {
  g_signal_connect_data_wd(
    $widget, $signal, &handler, OpaquePointer, Any, G_CONNECT_AFTER
  );
}

sub g_signal_connect_swapped_wd (
  N-GObject $widget, Str $signal,
  &handler ( N-GObject, OpaquePointer ), OpaquePointer
) {
  g_signal_connect_data_wd(
    $widget, $signal, &handler, OpaquePointer, Any, G_CONNECT_SWAPPED
  );
}

#-------------------------------------------------------------------------------
# safe in threaded programs
sub g_signal_connect_data_wd(
  N-GObject $widget, Str $signal,
  &handler ( N-GObject, OpaquePointer ), OpaquePointer $data,
  OpaquePointer $destroy_data, int32 $connect_flags
) returns int32
  is native(&gobject-lib)
  { * }

sub g_signal_connect_data_wwd(
  N-GObject $widget, Str $signal,
  &handler ( N-GObject, N-GObject, OpaquePointer ), OpaquePointer $data,
  OpaquePointer $destroy_data, int32 $connect_flags
) returns int32
  is native(&gobject-lib)
  { * }


# unsafe in threaded programs
#sub g_signal_connect_object(
#  N-GObject $widget, Str $signal, &handler ( N-GObject, OpaquePointer ),
#  OpaquePointer, int32 $connect_flags
#) returns uint32
#  is native(&gobject-lib)
#  { * }

# unsafe in threaded programs
sub g_signal_connect_object_wd(
  N-GObject $widget, Str $signal, &handler ( N-GObject, OpaquePointer ),
  OpaquePointer $data, int32 $connect_flags
) returns uint32
  is native(&gobject-lib)
  is symbol('g_signal_connect_object')
  { * }

sub g_signal_connect_object_wwd(
  N-GObject $widget, Str $signal, &handler (
    N-GObject, N-GObject, OpaquePointer
  ),
  OpaquePointer, int32 $connect_flags
) returns uint32
  is native(&gobject-lib)
  is symbol('g_signal_connect_object')
  { * }

sub g_signal_connect_object_wsd(
  N-GObject $widget, Str $signal, &handler (
    N-GObject, Str, OpaquePointer
  ),
  OpaquePointer, int32 $connect_flags
) returns uint32
  is native(&gobject-lib)
  is symbol('g_signal_connect_object')
  { * }

#`{{
# a GQuark is a guint32, $detail is a quark
# See https://developer.gnome.org/glib/stable/glib-Quarks.html
sub g_signal_emit (
  N-GObject $instance, uint32 $signal_id, uint32 $detail,
  N-GObject $widget, Str $data, Str $return-value is rw
) is native(&gobject-lib)
  { * }
}}

# Handlers above provided to the signal connect calls are having 2 arguments
# a widget and data. So the provided extra arguments are then those 2
# plus a return value
sub g_signal_emit_by_name_wd (
  # first two are obligatory by definition
  N-GObject $instance, Str $detailed_signal,
  # The rest depends on the handler defined when connecting
  # There is no return value from the handler
  N-GObject $widget, OpaquePointer
) is native(&gobject-lib)
  is symbol('g_signal_emit_by_name')
  { * }

sub g_signal_emit_by_name_wwd (
  # first two are obligatory by definition
  N-GObject $instance, Str $detailed_signal,
  # The rest depends on the handler defined when connecting
  # There is no return value from the handler
  N-GObject $widget1, N-GObject $widget2, OpaquePointer
) is native(&gobject-lib)
  is symbol('g_signal_emit_by_name')
  { * }

sub g_signal_handler_disconnect( N-GObject $widget, int32 $handler_id)
  is native(&gobject-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
has N-GObject $!g-object;

#-------------------------------------------------------------------------------
# Native object is handed over by GObject object
submethod BUILD ( N-GObject:D :$!g-object ) { }

#-------------------------------------------------------------------------------
method FALLBACK ( $native-sub is copy, Bool :$return-sub-only = False, |c ) {

  CATCH { test-catch-exception( $_, $native-sub); }

  $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-');
  die X::GTK::V3.new(:message(
      "Native sub name '$native-sub' made too short. Keep atleast one '-' or '_'."
    )
  ) unless $native-sub.index('_');

  my Callable $s;
  try { $s = &::($native-sub); }
  try { $s = &::("g_signal_$native-sub"); } unless ?$s;

  #test-call( $s, Any, |c)
  $return-sub-only ?? $s !! $s( $!g-object, |c)
}

#`{{
method fallback ( $native-sub is copy --> Callable ) {

  $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-');

  my Callable $s;
  try { $s = &::($native-sub); }
  try { $s = &::("g_signal_$native-sub"); } unless ?$s;

  #$s = callsame unless ?$s;

  $s
}
}}
