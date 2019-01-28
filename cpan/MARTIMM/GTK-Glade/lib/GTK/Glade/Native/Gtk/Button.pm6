use v6;
use NativeCall;

use GTK::Glade::NativeLib;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkbutton.h
unit module GTK::Glade::Native::Gtk::Button:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
sub gtk_button_new_with_label(Str $label)
    is native(&gtk-lib)
    is export
    returns GtkWidget
    { * }

sub gtk_button_get_label(GtkWidget $widget)
    is native(&gtk-lib)
    is export
    returns Str
    { * }

sub gtk_button_set_label(GtkWidget $widget, Str $label)
    is native(&gtk-lib)
    is export
    { * }
