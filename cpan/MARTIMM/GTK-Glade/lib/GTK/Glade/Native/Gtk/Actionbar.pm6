use v6;
use NativeCall;

use GTK::Glade::NativeLib;
#use GTK::Glade::Native::Gtk;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkactionbar.h
unit module GTK::Glade::Native::Gtk::Actionbar:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
sub gtk_action_bar_new()
    is native(&gtk-lib)
    is export
    returns GtkWidget
    { * }

sub gtk_action_bar_pack_start(GtkWidget $widget, GtkWidget $child)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_action_bar_pack_end(GtkWidget $widget, GtkWidget $child)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_action_bar_get_center_widget(GtkWidget $widget)
    is native(&gtk-lib)
    is export
    returns GtkWidget
    { * }

sub gtk_action_bar_set_center_widget(GtkWidget $widget, GtkWidget $centre-widget)
    is native(&gtk-lib)
    is export
    { * }
