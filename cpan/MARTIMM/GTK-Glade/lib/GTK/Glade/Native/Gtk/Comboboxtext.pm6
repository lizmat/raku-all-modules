use v6;
use NativeCall;

use GTK::Glade::NativeLib;
#use GTK::Glade::Native::Gtk;
#use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkcomboboxtext.h
unit module GTK::Glade::Native::Gtk::Comboboxtext:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
sub gtk_combo_box_text_new()
    is native(&gtk-lib)
    is export
    returns GtkWidget
    { * }

sub gtk_combo_box_text_new_with_entry()
    is native(&gtk-lib)
    is export
    returns GtkWidget
    { * }

sub gtk_combo_box_text_prepend_text(GtkWidget $widget, Str $text)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_combo_box_text_append_text(GtkWidget $widget, Str $text)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_combo_box_text_insert_text(GtkWidget $widget, int32 $position, Str $text)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_combo_box_set_active(GtkWidget $widget, int32 $index)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_combo_box_get_active(GtkWidget $widget)
    is native(&gtk-lib)
    is export
    returns int32
    { * }

sub gtk_combo_box_text_get_active_text(GtkWidget $widget)
    is native(&gtk-lib)
    is export
    returns Str
    { * }

sub gtk_combo_box_text_remove(GtkWidget $widget, int32 $position)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_combo_box_text_remove_all(GtkWidget $widget)
    is native(&gtk-lib)
    is export
    { * }
