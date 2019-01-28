use v6;
use NativeCall;

use GTK::Glade::NativeLib;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/gobject/gsignal.h
unit module GTK::Glade::Native::Glib::GSignal:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------

# gulong g_signal_connect_object ( gpointer instance,
#        const gchar *detailed_signal, GCallback c_handler,
#        gpointer gobject, GConnectFlags connect_flags);
sub g_signal_connect_object( GtkWidget $widget, Str $signal,
    &Handler ( GtkWidget $h_widget, OpaquePointer $h_data),
    OpaquePointer $data, int32 $connect_flags)
      returns uint32
      is native(&gobject-lib)
#      is symbol('g_signal_connect_object')
      is export
      { * }

sub g_signal_handler_disconnect( GtkWidget $widget, int32 $handler_id)
    is native(&gobject-lib)
    is export
    { * }

# from /usr/include/glib-2.0/gobject/gsignal.h
# #define g_signal_connect( instance, detailed_signal, c_handler, data)
# as g_signal_connect_data (
#      (instance), (detailed_signal),
#      (c_handler), (data), NULL, (GConnectFlags) 0
#    )
# So;
# gulong g_signal_connect_data ( gpointer instance,
#          const gchar *detailed_signal, GCallback c_handler,
#          gpointer data,  GClosureNotify destroy_data,
#          GConnectFlags connect_flags );
sub g_signal_connect_data( GtkWidget $widget, Str $signal,
    &Handler ( GtkWidget $h_widget, OpaquePointer $h_data),
    OpaquePointer $data, OpaquePointer $destroy_data, int32 $connect_flags
    ) returns int32
      is native(&gobject-lib)
      { * }

# a GQuark is a guint32, $detail is a quark
# See https://developer.gnome.org/glib/stable/glib-Quarks.html
sub g_signal_emit (
    OpaquePointer $instance, uint32 $signal_id, uint32 $detail,
    GtkWidget $widget, Str $data, Str $return-value is rw
    ) is native(&gobject-lib)
      is export
      { * }

sub g_signal_emit_by_name (
    OpaquePointer $instance, Str $detailed_signal,
    GtkWidget $widget, Str $data, Str $return-value is rw
    ) is native(&gobject-lib)
      is export
      { * }
