use v6;
use NativeCall;

use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gdk::GdkDisplay;
use GTK::V3::Gdk::GdkWindow;

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# /usr/include/gtk-3.0/gtk/gtkwidget.h
# https://developer.gnome.org/gtk3/stable/GtkWidget.html
unit class GTK::V3::Gtk::GtkWidget:auth<github:MARTIMM>
  is GTK::V3::Glib::GObject;

#-------------------------------------------------------------------------------
sub gtk_widget_get_display ( N-GObject $widget )
  returns N-GObject       # GdkDisplay
  is native(&gtk-lib)
  { * }

sub gtk_widget_get_no_show_all ( N-GObject $widgetw )
  returns int32
  is native(&gtk-lib)
  { * }

sub gtk_widget_get_visible ( N-GObject $widget )
  returns int32       # Bool 1=true
  is native(&gtk-lib)
  { * }

sub gtk_widget_hide ( N-GObject $widgetw )
  is native(&gtk-lib)
  { * }

sub gtk_widget_set_no_show_all ( N-GObject $widgetw, int32 $no_show_all )
  is native(&gtk-lib)
  { * }

sub gtk_widget_show ( N-GObject $widgetw )
  is native(&gtk-lib)
  { * }

sub gtk_widget_show_all ( N-GObject $widgetw )
  is native(&gtk-lib)
  { * }

sub gtk_widget_destroy ( N-GObject $widget )
  is native(&gtk-lib)
  { * }

sub gtk_widget_set_sensitive ( N-GObject $widget, int32 $sensitive )
  is native(&gtk-lib)
  { * }

sub gtk_widget_get_sensitive ( N-GObject $widget )
  returns int32
  is native(&gtk-lib)
  { * }

sub gtk_widget_set_size_request ( N-GObject $widget, int32 $w, int32 $h )
  is native(&gtk-lib)
  { * }

sub gtk_widget_get_allocated_height ( N-GObject $widget )
  returns int32
  is native(&gtk-lib)
  { * }

sub gtk_widget_get_allocated_width ( N-GObject $widget )
  returns int32
  is native(&gtk-lib)
  { * }

sub gtk_widget_queue_draw ( N-GObject $widget )
  is native(&gtk-lib)
  { * }

sub gtk_widget_get_tooltip_text ( N-GObject $widget )
  returns Str
  is native(&gtk-lib)
  { * }

sub gtk_widget_set_tooltip_text ( N-GObject $widget, Str $text )
  is native(&gtk-lib)
  { * }

# void gtk_widget_set_name ( N-GObject *widget, const gchar *name );
sub gtk_widget_set_name ( N-GObject $widget, Str $name )
  is native(&gtk-lib)
  { * }

# const gchar *gtk_widget_get_name ( N-GObject *widget );
sub gtk_widget_get_name ( N-GObject $widget )
  returns Str
  is native(&gtk-lib)
  { * }

sub gtk_widget_get_window ( N-GObject $widget )
  returns N-GObject         # GdkWindow
  is native(&gtk-lib)
  { * }

sub gtk_widget_set_visible ( N-GObject $widget, Bool $visible)
  is native(&gtk-lib)
  { * }

sub gtk_widget_get_has_window ( N-GObject $window )
  returns Bool
  is native(&gtk-lib)
  { * }


# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
method fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
#note "w s0: $native-sub, ", $s;
  try { $s = &::($native-sub); }
#note "w s1: gtk_widget_$native-sub, ", $s unless ?$s;
  try { $s = &::("gtk_widget_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s
}
