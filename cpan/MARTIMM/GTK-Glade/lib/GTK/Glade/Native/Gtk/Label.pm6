use v6;
use NativeCall;

use GTK::Glade::NativeLib;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtklabel.h
unit module GTK::Glade::Native::Gtk::Label:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
sub gtk_label_new ( Str $text )
  returns GtkWidget
  is native(&gtk-lib)
  is export
  { * }

#-------------------------------------------------------------------------------
sub gtk_label_get_text ( GtkWidget $label )
  returns Str
  is native(&gtk-lib)
  is export
  { * }

#-------------------------------------------------------------------------------
sub gtk_label_set_text ( GtkWidget $label, Str $text )
  is native(&gtk-lib)
  is export
  { * }

#-------------------------------------------------------------------------------
sub gtk_label_set_markup( GtkWidget $label, Str $text )
  is native(&gtk-lib)
  is export
  { * }
