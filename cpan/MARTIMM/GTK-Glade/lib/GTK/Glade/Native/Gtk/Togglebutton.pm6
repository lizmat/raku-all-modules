use v6;
use NativeCall;

use GTK::Glade::NativeLib;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtktogglbutton.h
unit module GTK::Glade::Native::Gtk::Togglebutton:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
sub gtk_toggle_button_new_with_label ( Str $label )
    returns GtkWidget
    is native(&gtk-lib)
    is export
    { * }

sub gtk_toggle_button_get_active ( GtkWidget $w )
    returns int32
    is native(&gtk-lib)
    is export
    { * }

sub gtk_toggle_button_set_active ( GtkWidget $w, int32 $active )
    returns int32
    is native(&gtk-lib)
    is export
    { * }
