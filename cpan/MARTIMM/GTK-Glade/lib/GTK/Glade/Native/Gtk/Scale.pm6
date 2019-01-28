use v6;
use NativeCall;

use GTK::Glade::NativeLib;
#use GTK::Glade::Native::Gtk;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkscale.h
unit module GTK::Glade::Native::Gtk::Scale:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
# GtkOrientation from Enums:
#   horizontal = GTK_ORIENTATION_HORIZONTAL
#   vertical = GTK_ORIENTATION_VERTICAL
sub gtk_scale_new_with_range( int32 $orientation, num64 $min, num64 $max, num64 $step )
    is native(&gtk-lib)
    is export
    returns GtkWidget
    { * }

# inverts so that big numbers at top.
sub gtk_scale_set_digits( GtkWidget $scale, int32 $digits )
    is native( &gtk-lib)
    is export
    { * }

sub gtk_range_get_value( GtkWidget $scale )
    is native(&gtk-lib)
    is export
    returns num64
    { * }

sub gtk_range_set_value( GtkWidget $scale, num64 $value )
    is native(&gtk-lib)
    is export
    { * }

sub gtk_range_set_inverted( GtkWidget $scale, Bool $invertOK )
    is native(&gtk-lib)
    is export
    { * }
