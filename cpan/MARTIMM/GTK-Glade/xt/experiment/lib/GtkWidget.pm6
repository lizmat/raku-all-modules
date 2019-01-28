use v6;
use NativeCall;

use N::NativeLib;
use GdkScreen;
use GdkDisplay;
use GdkWindow;

#-------------------------------------------------------------------------------
class N-GtkWidget
  is repr('CPointer')
  is export
  { }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
role GtkWidget is Callable {

  #-----------------------------------------------------------------------------
  sub gtk_widget_get_display ( N-GtkWidget $widget )
    returns N-GdkDisplay
    is native(&gtk-lib)
    is export
    { * }

  sub gtk_widget_get_no_show_all ( N-GtkWidget $widgetw )
    returns int32
    is native(&gtk-lib)
    is export
    { * }

  sub gtk_widget_hide ( N-GtkWidget $widgetw )
    is native(&gtk-lib)
    is export
    { * }

  sub gtk_widget_set_no_show_all ( N-GtkWidget $widgetw, int32 $no_show_all )
    is native(&gtk-lib)
    is export
    { * }

  sub gtk_widget_show ( N-GtkWidget $widgetw )
    is native(&gtk-lib)
    is export
    { * }

  sub gtk_widget_show_all ( N-GtkWidget $widgetw )
    is native(&gtk-lib)
    is export
    { * }

  sub gtk_widget_destroy ( N-GtkWidget $widget )
    is native(&gtk-lib)
    is export
    { * }

  sub gtk_widget_set_sensitive ( N-GtkWidget $widget, int32 $sensitive )
    is native(&gtk-lib)
    is export
    { * }

  sub gtk_widget_get_sensitive ( N-GtkWidget $widget )
    returns int32
    is native(&gtk-lib)
    is export
    { * }

  sub gtk_widget_set_size_request ( N-GtkWidget $widget, int32 $w, int32 $h )
    is native(&gtk-lib)
    is export
    { * }

  sub gtk_widget_get_allocated_height ( N-GtkWidget $widget )
    returns int32
    is native(&gtk-lib)
    is export
    { * }

  sub gtk_widget_get_allocated_width ( N-GtkWidget $widget )
    returns int32
    is native(&gtk-lib)
    is export
    { * }

  sub gtk_widget_queue_draw ( N-GtkWidget $widget )
    is native(&gtk-lib)
    is export
    { * }

  sub gtk_widget_get_tooltip_text ( N-GtkWidget $widget )
    is native(&gtk-lib)
    is export
    returns Str
    { * }

  sub gtk_widget_set_tooltip_text ( N-GtkWidget $widget, Str $text )
    is native(&gtk-lib)
    is export
    { * }

  # void gtk_widget_set_name ( N-GtkWidget *widget, const gchar *name );
  sub gtk_widget_set_name ( N-GtkWidget $widget, Str $name )
    is native(&gtk-lib)
    is export
    { * }

  # const gchar *gtk_widget_get_name ( N-GtkWidget *widget );
  sub gtk_widget_get_name ( N-GtkWidget $widget )
    returns Str
    is native(&gtk-lib)
    is export
    { * }

  sub gtk_widget_get_window ( N-GtkWidget $widget )
    returns N-GdkWindow
    is native(&gtk-lib)
    is export
    { * }

  sub gtk_widget_set_visible ( N-GtkWidget $widget, Bool $visible)
    is native(&gtk-lib)
    is export
    { * }

  sub gtk_widget_get_has_window ( N-GtkWidget $window )
    returns Bool
    is native(&gtk-lib)
    is export
    { * }

  # = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
  has N-GtkWidget $!gtk-widget;

  #-----------------------------------------------------------------------------
  method CALL-ME ( N-GtkWidget $widget? --> N-GtkWidget ) {

    if ?$widget {
      #if GdkWindow::GDK_WINDOW_TOPLEVEL
      #$!gtk-widget = N-GtkWidget;
      $!gtk-widget = $widget;
    }

    $!gtk-widget
  }

  #-----------------------------------------------------------------------------
  method FALLBACK ( $native-sub is copy, |c ) {

    $native-sub ~~ s:g/ '-' /_/;
#note "w name: $native-sub";
#note "w this: ", self.WHAT;
#    my $class = self.WHAT;

    my &s;
#note "w s0: $native-sub, ", &s;
    try { &s = &::($native-sub); }
#note "w s1: gtk_widget_$native-sub, ", &s unless ?&s;
    try { &s = &::('gtk_widget_' ~ $native-sub); } unless ?&s;
#`{{
    my Str $widget-type = self.^name;
note "w s2: $widget-type :: $native-sub, ", &s unless ?&s;
    try { &s = &::("$widget-type")::("$native-sub"); } unless ?&s;
note "w s3: $widget-type :: gtk_label_$native-sub, ", &s unless ?&s;
    try { &s = &::($widget-type)::('gtk_label_' ~ $native-sub); } unless ?&s;
}}
    CATCH {
      default {
        note "w Cannot call $native-sub. Sub is not found";
        note .message;
      }
    }

#note "w s: ", &s;
    &s( $!gtk-widget, |c)
  }

#`{{
  #-----------------------------------------------------------------------------
  method test-sub-name ( Str $native-sub --> Routine ) {

    try {
      my &s = &::($native-sub);
note "s: ", &s;
#      &s( $!gtk-widget, |c);
      return &s;


      CATCH {
        default {
          note "Cannot call $native-sub. Sub is not found";
        }
      }
    }
  }
}}
}
