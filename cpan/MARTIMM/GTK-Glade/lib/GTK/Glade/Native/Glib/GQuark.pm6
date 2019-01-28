use v6;
use NativeCall;

use GTK::Glade::NativeLib;
#use GTK::Glade::Native::Gtk;
#use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/glib/gquark.h
unit module GTK::Glade::Native::Gtk::GQuark:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
sub g_quark_from_string ( Str $string )
    returns uint32
    is native(&glib-lib)
    is export
    { * }

sub g_quark_to_string ( uint32 $quark )
    returns Str
    is native(&glib-lib)
    is export
    { * }
