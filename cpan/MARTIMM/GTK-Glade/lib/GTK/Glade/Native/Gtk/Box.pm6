use v6;
use NativeCall;

use GTK::Glade::NativeLib;
#use GTK::Glade::Native::Gtk;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkbox.h
unit module GTK::Glade::Native::Gtk::Box:auth<github:MARTIMM>;

#--[ Box ]----------------------------------------------------------------------
sub gtk_box_new ( uint32 $orientation, int32 $spacing )
    returns GtkWidget
    is DEPRECATED('grid')
    is native(&gtk-lib)
    is export
    { * }

sub gtk_box_pack_start ( GtkWidget, GtkWidget, Bool, Bool, uint32 )
    is native(&gtk-lib)
    is export
    { * }

sub gtk_box_get_spacing ( GtkWidget $box )
    returns int32
    is native(&gtk-lib)
    is export
    { * }

sub gtk_box_set_spacing ( GtkWidget $box, int32 $spacing )
    is native(&gtk-lib)
    is export
    { * }

#--[ HBox ]---------------------------------------------------------------------
sub gtk_hbox_new(int32, int32)
    returns GtkWidget
    is DEPRECATED('grid')
    is native(&gtk-lib)
    is export
    { * }

#--[ VBox ]---------------------------------------------------------------------
sub gtk_vbox_new(int32, int32)
    returns GtkWidget
    is DEPRECATED('grid')
    is native(&gtk-lib)
    is export
    { * }
