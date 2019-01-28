use v6;
use NativeCall;

use GTK::Glade::NativeLib;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtklistbox.h
unit module GTK::Glade::Native::Gtk::Listbox:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
sub gtk_list_box_insert ( GtkWidget $box, GtkWidget $child, int32 $position)
    is native(&gtk-lib)
    is export
    { * }

# The widget in the argument list is a GtkListBox
# returned widget is a GtkListBoxRow
sub gtk_list_box_get_row_at_index ( GtkWidget $box, int32 $index)
    returns GtkWidget
    is native(&gtk-lib)
    is export
    { * }
