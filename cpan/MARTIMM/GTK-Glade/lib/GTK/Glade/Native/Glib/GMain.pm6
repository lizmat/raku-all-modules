use v6;
use NativeCall;

use GTK::Glade::NativeLib;
#use GTK::Glade::Native::Gtk;
#use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/gmain.h
unit module GTK::Glade::Native::Glib::GMain:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
sub g_idle_add( &Handler (OpaquePointer $h_data), OpaquePointer $data)
    returns int32
    is native(&glib-lib)
    is export
    { * }

sub g_timeout_add(
    int32 $interval, &Handler (OpaquePointer $h_data, --> int32),
    OpaquePointer $data
    )  returns int32
      is native(&gtk-lib)
      is export
      { * }
