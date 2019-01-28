use v6;
use NativeCall;

use GTK::Glade::NativeLib;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkcheckbutton.h
unit module GTK::Glade::Native::Gtk::Checkbutton:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
sub gtk_check_button_new_with_label ( Str $label )
    returns GtkWidget
    is native(&gtk-lib)
    is export
    { * }
