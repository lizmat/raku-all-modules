use v6;
use NativeCall;

use GTK::Glade::NativeLib;
#use GTK::Glade::Native::Gtk;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkrange.h
unit module GTK::Glade::Native::Gtk::Range:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
sub gtk_range_get_value( GtkWidget $scale )
    is native(&gtk-lib)
    is export
    returns num64
    { * }

sub gtk_range_set_value( GtkWidget $scale, num64 $value )
    is native(&gtk-lib)
    is export
    { * }

sub gtk_range_set_inverted( GtkWidget $scale, Bool $invertOK )
    is native(&gtk-lib)
    is export
    { * }
