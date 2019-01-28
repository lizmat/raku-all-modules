use v6;
use NativeCall;

use GTK::Glade::NativeLib;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/glib/glist.h
unit module GTK::Glade::Native::Glib::GList:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
#`{{
class GList is repr('CStruct') {
  OpaquePointer $data;
  GList $next;
  GList $prev;
}
}}

#-------------------------------------------------------------------------------
sub g_list_length ( OpaquePointer $list )
    returns uint32
    is native(&glib-lib)
    is export
    { * }

sub g_list_nth_data ( OpaquePointer $list, uint32 $n)
    returns GtkWidget
    is native(&glib-lib)
    is export
    { * }
