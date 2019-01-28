use v6;
use NativeCall;

use GTK::Glade::NativeLib;
#use GTK::Glade::Native::Gtk;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkcontainer.h
unit module GTK::Glade::Native::Gtk::Container:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
sub gtk_container_add ( GtkWidget $container, GtkWidget $widget )
    is native(&gtk-lib)
    is export
    { * }

sub gtk_container_get_border_width ( GtkWidget $container )
    returns int32
    is native(&gtk-lib)
    is export
    { * }

sub gtk_container_set_border_width ( GtkWidget $container, int32 $border_width )
    is native(&gtk-lib)
    is export
    { * }

sub gtk_container_get_children ( GtkWidget $container )
    returns OpaquePointer
    is native(&gtk-lib)
    is export
    { * }
