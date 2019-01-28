use v6;
use NativeCall;

use GTK::Glade::NativeLib;
#use GTK::Glade::Native::Gtk;
use GTK::Glade::Native::Gdk;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkwidget.h
unit module GTK::Glade::Native::Gtk::Widget:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
class GtkWidget is repr('CPointer') is export { }

sub gtk_widget_get_display ( GtkWidget $widget )
    returns GdkDisplay
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_show(GtkWidget $widgetw)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_hide(GtkWidget $widgetw)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_show_all(GtkWidget $widgetw)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_set_no_show_all(GtkWidget $widgetw, int32 $no_show_all)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_get_no_show_all(GtkWidget $widgetw)
    returns int32
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_destroy(GtkWidget $widget)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_set_sensitive(GtkWidget $widget, int32 $sensitive)
    is native(&gtk-lib)
    is export

    { * }
sub gtk_widget_get_sensitive(GtkWidget $widget)
    returns int32
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_set_size_request(GtkWidget $widget, int32 $w, int32 $h)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_get_allocated_height(GtkWidget $widget)
    returns int32
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_get_allocated_width(GtkWidget $widget)
    returns int32
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_queue_draw(GtkWidget $widget)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_get_tooltip_text(GtkWidget $widget)
    is native(&gtk-lib)
    is export
    returns Str
    { * }

sub gtk_widget_set_tooltip_text(GtkWidget $widget, Str $text)
    is native(&gtk-lib)
    is export
    { * }

# void gtk_widget_set_name ( GtkWidget *widget, const gchar *name );
sub gtk_widget_set_name ( GtkWidget $widget, Str $name )
    is native(&gtk-lib)
    is export
    { * }

# const gchar *gtk_widget_get_name ( GtkWidget *widget );
sub gtk_widget_get_name ( GtkWidget $widget )
    returns Str
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_get_window ( GtkWidget $widget )
    returns GdkWindow
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_set_visible ( GtkWidget $widget, Bool $visible)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_get_has_window ( GtkWidget $window )
    returns Bool
    is native(&gtk-lib)
    is export
    { * }
