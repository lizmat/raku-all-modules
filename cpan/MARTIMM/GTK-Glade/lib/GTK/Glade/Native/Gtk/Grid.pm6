use v6;
use NativeCall;

use GTK::Glade::NativeLib;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkgrid.h
unit module GTK::Glade::Native::Gtk::Grid:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
sub gtk_grid_new()
    returns GtkWidget
    is native(&gtk-lib)
    is export
    { * }

sub gtk_grid_attach( GtkWidget $grid, GtkWidget $child, int32 $x, int32 $y,
    int32 $w, int32 $h
    ) is native(&gtk-lib)
      is export
      { * }

sub gtk_grid_insert_row ( GtkWidget $grid, int32 $position)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_grid_insert_column ( GtkWidget $grid, int32 $position)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_grid_get_child_at ( GtkWidget $grid, uint32 $left, uint32 $top)
    returns GtkWidget
    is native(&gtk-lib)
    is export
    { * }
