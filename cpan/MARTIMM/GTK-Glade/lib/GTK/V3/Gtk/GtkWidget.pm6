use v6;
use NativeCall;

use GTK::Glade::Gui;
use GTK::V3::N::NativeLib;
use GTK::V3::Gdk::GdkScreen;
use GTK::V3::Gdk::GdkDisplay;
use GTK::V3::Gdk::GdkWindow;

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
class GTK::V3::Gtk::GtkWidget:auth<github:MARTIMM> {

  #-----------------------------------------------------------------------------
  sub gtk_widget_get_display ( N-GtkWidget $widget )
    returns N-GdkDisplay
    is native(&gtk-lib)
#    is export
    { * }

  sub gtk_widget_get_no_show_all ( N-GtkWidget $widgetw )
    returns int32
    is native(&gtk-lib)
#    is export
    { * }

  sub gtk_widget_get_visible ( N-GtkWidget $widget )
    returns int32       # Bool 1=true
    is native(&gtk-lib)
#    is export
    { * }

  sub gtk_widget_hide ( N-GtkWidget $widgetw )
    is native(&gtk-lib)
#    is export
    { * }

  sub gtk_widget_set_no_show_all ( N-GtkWidget $widgetw, int32 $no_show_all )
    is native(&gtk-lib)
#    is export
    { * }

  sub gtk_widget_show ( N-GtkWidget $widgetw )
    is native(&gtk-lib)
#    is export
    { * }

  sub gtk_widget_show_all ( N-GtkWidget $widgetw )
    is native(&gtk-lib)
#    is export
    { * }

  sub gtk_widget_destroy ( N-GtkWidget $widget )
    is native(&gtk-lib)
#    is export
    { * }

  sub gtk_widget_set_sensitive ( N-GtkWidget $widget, int32 $sensitive )
    is native(&gtk-lib)
#    is export
    { * }

  sub gtk_widget_get_sensitive ( N-GtkWidget $widget )
    returns int32
    is native(&gtk-lib)
#    is export
    { * }

  sub gtk_widget_set_size_request ( N-GtkWidget $widget, int32 $w, int32 $h )
    is native(&gtk-lib)
#    is export
    { * }

  sub gtk_widget_get_allocated_height ( N-GtkWidget $widget )
    returns int32
    is native(&gtk-lib)
#    is export
    { * }

  sub gtk_widget_get_allocated_width ( N-GtkWidget $widget )
    returns int32
    is native(&gtk-lib)
#    is export
    { * }

  sub gtk_widget_queue_draw ( N-GtkWidget $widget )
    is native(&gtk-lib)
#    is export
    { * }

  sub gtk_widget_get_tooltip_text ( N-GtkWidget $widget )
    is native(&gtk-lib)
    is export
#    returns Str
    { * }

  sub gtk_widget_set_tooltip_text ( N-GtkWidget $widget, Str $text )
    is native(&gtk-lib)
#    is export
    { * }

  # void gtk_widget_set_name ( N-GtkWidget *widget, const gchar *name );
  sub gtk_widget_set_name ( N-GtkWidget $widget, Str $name )
    is native(&gtk-lib)
#    is export
    { * }

  # const gchar *gtk_widget_get_name ( N-GtkWidget *widget );
  sub gtk_widget_get_name ( N-GtkWidget $widget )
    returns Str
    is native(&gtk-lib)
#    is export
    { * }

  sub gtk_widget_get_window ( N-GtkWidget $widget )
    returns N-GdkWindow
    is native(&gtk-lib)
#    is export
    { * }

  sub gtk_widget_set_visible ( N-GtkWidget $widget, Bool $visible)
    is native(&gtk-lib)
#    is export
    { * }

  sub gtk_widget_get_has_window ( N-GtkWidget $window )
    returns Bool
    is native(&gtk-lib)
#    is export
    { * }

  # = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
  method fallback ( $native-sub is copy --> Callable ) {

    $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-');

    my Callable $s;
#note "w s0: $native-sub, ", $s;
    try { $s = &::($native-sub); }
#note "w s1: gtk_widget_$native-sub, ", $s unless ?$s;
    try { $s = &::("gtk_widget_$native-sub"); } unless ?$s;

    $s
  }
}
