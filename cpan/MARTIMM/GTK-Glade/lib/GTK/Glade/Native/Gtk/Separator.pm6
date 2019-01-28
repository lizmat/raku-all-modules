use v6;
use NativeCall;

use GTK::Glade::NativeLib;
#use GTK::Glade::Native::Gtk;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkscale.h
unit module GTK::Glade::Native::Gtk::Scale:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
# GtkOrientation from Enums:
#   horizontal = GTK_ORIENTATION_HORIZONTAL
#   vertical = GTK_ORIENTATION_VERTICAL
sub gtk_separator_new ( int32 $orientation )
    returns GtkWidget
    is native(&gtk-lib)
    is export
    { * }
