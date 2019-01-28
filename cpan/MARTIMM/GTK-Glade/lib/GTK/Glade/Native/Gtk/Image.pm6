use v6;
use NativeCall;

use GTK::Glade::NativeLib;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtklistbox.h
unit module GTK::Glade::Native::Gtk::Image:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
enum GtkImageType  is export <
  GTK_IMAGE_EMPTY
  GTK_IMAGE_PIXBUF
  GTK_IMAGE_STOCK
  GTK_IMAGE_ICON_SET
  GTK_IMAGE_ANIMATION
  GTK_IMAGE_ICON_NAME
  GTK_IMAGE_GICON
  GTK_IMAGE_SURFACE
>;

#-------------------------------------------------------------------------------
sub gtk_image_new ( )
    returns GtkWidget
    is native(&gtk-lib)
    is export
    { * }

sub gtk_image_new_from_file ( Str $filename )
    returns GtkWidget
    is native(&gtk-lib)
    is export
    { * }

# image is a GtkImage
sub gtk_image_set_from_file ( GtkWidget $image, Str $filename)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_image_clear ( GtkWidget $image )
    is native(&gtk-lib)
    is export
    { * }

# GtkImageType is an enum -> uint32
sub gtk_image_get_storage_type ( GtkWidget $image )
    returns uint32
    is native(&gtk-lib)
    is export
    { * }

sub gtk_image_get_pixbuf ( GtkWidget $image )
    returns OpaquePointer
    is native(&gtk-lib)
    is export
    { * }
