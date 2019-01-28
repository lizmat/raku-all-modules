use v6;
use NativeCall;

use GTK::Glade::NativeLib;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkentry.h
unit module GTK::Glade::Native::Gtk::Entry:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
# Entries are of type GtkEntry
sub gtk_entry_new ( )
    returns GtkWidget
    is native(&gtk-lib)
    is export
    { * }

sub gtk_entry_get_text ( GtkWidget $entry )
    returns Str
    is native(&gtk-lib)
    is export
    { * }

sub gtk_entry_set_text ( GtkWidget $entry, Str $text )
    is native(&gtk-lib)
    is export
    { * }

sub gtk_entry_set_visibility ( GtkWidget $entry, Bool $visible )
    is native(&gtk-lib)
    is export
    { * }

# hints is an enum with type GtkInputHints -> int
# The values are defined in Enums.pm6
sub gtk_entry_set_input_hints ( GtkWidget $entry, uint32 $hints )
    is native(&gtk-lib)
    is export
    { * }
