use v6;
use NativeCall;

use GTK::Glade::NativeLib;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkframe.h
unit module GTK::Glade::Native::Gtk::Frame:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
sub gtk_frame_new(Str $label)
    is native(&gtk-lib)
    is export
    returns GtkWidget
    { * }

sub gtk_frame_get_label(GtkWidget $widget)
    is native(&gtk-lib)
    is export
    returns Str
    { * }

sub gtk_frame_set_label(GtkWidget $widget, Str $label)
    is native(&gtk-lib)
    is export
    { * }
