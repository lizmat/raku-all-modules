use v6;
# ==============================================================================
=begin pod

=TITLE class GTK::V3::Gtk::GtkWidget

=SUBTITLE

  unit class GTK::V3::Gtk::GtkWidget;
  also is GTK::V3::Gtk::GInitiallyUnowned;

=head2 GtkWidget — Base class for all widgets

=head1 Synopsis

  # create a button and set a tooltip
  my GTK::V3::Gtk::GtkButton $start-button .= new(:label<Start>);
  $start-button.set-tooltip-text('Nooooo don\'t touch that button!!!!!!!');

=end pod
# ==============================================================================
use NativeCall;

use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Glib::GInitiallyUnowned;

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# /usr/include/gtk-3.0/gtk/gtkwidget.h
# https://developer.gnome.org/gtk3/stable/GtkWidget.html
unit class GTK::V3::Gtk::GtkWidget:auth<github:MARTIMM>;
also is GTK::V3::Glib::GInitiallyUnowned;

# ==============================================================================
=begin pod
=head1 Methods

=head2 gtk_widget_destroy

  method gtk_widget_destroy ( )

Destroys a native widget. When a widget is destroyed all references it holds on other objects will be released:

=item if the widget is inside a container, it will be removed from its parent

=item if the widget is a container, all its children will be destroyed, recursively

=item if the widget is a top level, it will be removed from the list of top level widgets that GTK+ maintains internally

It's expected that all references held on the widget will also be released; you should connect to the “destroy” signal if you hold a reference to widget and you wish to remove it when this function is called. It is not necessary to do so if you are implementing a GtkContainer, as you'll be able to use the GtkContainerClass.remove() virtual function for that.

It's important to notice that gtk_widget_destroy() will only cause the widget to be finalized if no additional references, acquired using g_object_ref(), are held on it. In case additional references are in place, the widget will be in an "inert" state after calling this function; widget will still point to valid memory, allowing you to release the references you hold, but you may not query the widget's own state.

You should typically call this function on top level widgets, and rarely on child widgets.

See also: gtk_container_remove()
=end pod
sub gtk_widget_destroy ( N-GObject $widget is rw ) {
  hidden_gtk_widget_destroy( $widget );
  #GOBject.g_clear_object($widget)
  $widget = N-GObject; # not needed after clearing!
}
sub hidden_gtk_widget_destroy ( N-GObject $widget )
  is native(&gtk-lib)
  is symbol('')
  { * }

# ==============================================================================
=begin pod
=head2 gtk_widget_show

  method gtk_widget_show ( )

Flags a widget to be displayed. Any widget that isn’t shown will not appear on the screen. If you want to show all the widgets in a container, it’s easier to call gtk_widget_show_all() on the container, instead of individually showing the widgets.

Remember that you have to show the containers containing a widget, in addition to the widget itself, before it will appear onscreen.

When a toplevel container is shown, it is immediately realized and mapped; other shown widgets are realized and mapped when their toplevel container is realized and mapped.
=end pod
sub gtk_widget_show ( N-GObject $widget )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 gtk_widget_hide

  method gtk_widget_hide ( )

Reverses the effects of gtk_widget_show().
=end pod
sub gtk_widget_hide ( N-GObject $widgetw )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_widget_] show_all

  method gtk_widget_show_all ( )

Recursively shows a widget, and any child widgets (if the widget is a container).
=end pod
sub gtk_widget_show_all ( N-GObject $widget )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_widget_] get_display

  method gtk_widget_get_display ( )

Get the GdkDisplay for the toplevel window associated with this widget. This function can only be called after the widget has been added to a widget hierarchy with a GtkWindow at the top.

In general, you should only create display specific resources when a widget has been realized, and you should free those resources when the widget is unrealized.
=end pod
sub gtk_widget_get_display ( N-GObject $widget )
  returns N-GObject       # GdkDisplay
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_widget_] set_name

  method gtk_widget_set_name ( Str $name )

Widgets can be named, which allows you to refer to them from a CSS file. You can apply a style to widgets with a particular name in the CSS file. See the documentation for the CSS syntax (on the same page as the L<docs for GtkStyleContext|https://developer.gnome.org/gtk3/stable/GtkStyleContext.html>).

Note that the CSS syntax has certain special characters to delimit and represent elements in a selector (period, #, >, *...), so using these will make your widget impossible to match by name. Any combination of alphanumeric symbols, dashes and underscores will suffice.
=end pod
sub gtk_widget_set_name ( N-GObject $widget, Str $name )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_widget_] get_name

  method gtk_widget_get_name ( )

Retrieves the name of a widget. See gtk_widget_set_name() for the significance of widget names.
=end pod
sub gtk_widget_get_name ( N-GObject $widget )
  returns Str
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_widget_] set_sensitive

  method gtk_widget_set_sensitive ( Bool $sensitive )

Sets the sensitivity of a widget. A widget is sensitive if the user can interact with it. Insensitive widgets are “grayed out” and the user can’t interact with them. Insensitive widgets are known as “inactive”, “disabled”, or “ghosted” in some other toolkits.
=end pod
sub gtk_widget_set_sensitive ( N-GObject $widget, Bool $sensitive ) {
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_widget_] get_sensitive

  method gtk_widget_get_sensitive ( --> Bool )

Returns the widget’s sensitivity (in the sense of returning the value that has been set using gtk_widget_set_sensitive()).

The effective sensitivity of a widget is however determined by both its own and its parent widget’s sensitivity. See gtk_widget_is_sensitive().
=end pod
sub gtk_widget_get_sensitive ( N-GObject $widget --> Bool ) {
  ? hidden_gtk_widget_get_sensitive($widget)
}
sub hidden_gtk_widget_get_sensitive ( N-GObject $widget )
  returns int32
  is native(&gtk-lib)
  is symbol('gtk_widget_get_sensitive')
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_widget_] set_size_request

  method gtk_widget_set_size_request ( Int $w, Int $h )

Sets the minimum size of a widget; that is, the widget’s size request will be at least width by height . You can use this function to force a widget to be larger than it normally would be.

In most cases, gtk_window_set_default_size() is a better choice for toplevel windows than this function; setting the default size will still allow users to shrink the window. Setting the size request will force them to leave the window at least as large as the size request. When dealing with window sizes, gtk_window_set_geometry_hints() can be a useful function as well.

Note the inherent danger of setting any fixed size - themes, translations into other languages, different fonts, and user action can all change the appropriate size for a given widget. So, it's basically impossible to hardcode a size that will always be correct.

The size request of a widget is the smallest size a widget can accept while still functioning well and drawing itself correctly. However in some strange cases a widget may be allocated less than its requested size, and in many cases a widget may be allocated more space than it requested.

If the size request in a given direction is -1 (unset), then the “natural” size request of the widget will be used instead.

The size request set here does not include any margin from the GtkWidget properties margin-left, margin-right, margin-top, and margin-bottom, but it does include pretty much all other padding or border properties set by any subclass of GtkWidget.
=end pod
sub gtk_widget_set_size_request ( N-GObject $widget, int32 $w, int32 $h )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_widget_] set_no_show_all

  method gtk_widget_set_no_show_all ( Bool $no_show_all )

Sets the “no-show-all” property, which determines whether calls to gtk_widget_show_all() will affect this widget.

This is mostly for use in constructing widget hierarchies with externally controlled visibility.
=end pod
#TODO ref to GtkUIManager when implemented.
sub gtk_widget_set_no_show_all ( N-GObject $widget, Bool $no_show_all ) {
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_widget_] get_no_show_all

  method gtk_widget_get_no_show_all ( --> Bool )

Returns the current value of the “no-show-all” property, which determines whether calls to gtk_widget_show_all() will affect this widget.
=end pod
sub gtk_widget_get_no_show_all ( N-GObject $widget --> Bool ) {
  ? hidden_gtk_widget_get_no_show_all($widget)
}
sub hidden_gtk_widget_get_no_show_all ( N-GObject $widget )
  returns int32
  is native(&gtk-lib)
  is symbol('gtk_widget_get_no_show_all')
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_widget_] get_allocated_width

  method gtk_widget_get_allocated_width ( --> Int )

Returns the width that has currently been allocated to widget . This function is intended to be used when implementing handlers for the “draw” function.
=end pod
sub gtk_widget_get_allocated_width ( N-GObject $widget )
  returns int32
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_widget_] get_allocated_height

  method gtk_widget_get_allocated_height ( --> Int )

Returns the height that has currently been allocated to widget . This function is intended to be used when implementing handlers for the “draw” function.
=end pod
sub gtk_widget_get_allocated_height ( N-GObject $widget )
  returns int32
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_widget_] queue_draw

  method gtk_widget_queue_draw ( )

Equivalent to calling gtk_widget_queue_draw_area() for the entire area of a widget.
=end pod
sub gtk_widget_queue_draw ( N-GObject $widget )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_widget_] get_tooltip_text

  method gtk_widget_get_tooltip_text ( --> Str )

Returns the GtkWindow of the current tooltip. This can be the GtkWindow created by default, or the custom tooltip window set using gtk_widget_set_tooltip_window().
=end pod
sub gtk_widget_get_tooltip_text ( N-GObject $widget )
  returns Str
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_widget_] set_tooltip_text

  method gtk_widget_set_tooltip_text ( Str $text )

Sets text as the contents of the tooltip. This function will take care of setting “has-tooltip” to TRUE and of the default handler for the “query-tooltip” signal.
=end pod
sub gtk_widget_set_tooltip_text ( N-GObject $widget, Str $text )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_widget_] get_tooltip_text

  method gtk_widget_get_tooltip_text ( --> Str )

Sets text as the contents of the tooltip. This function will take care of setting “has-tooltip” to TRUE and of the default handler for the “query-tooltip” signal.
=end pod
sub gtk_widget_get_tooltip_text ( N-GObject $widget )
  returns Str
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_widget_] get_window

  method gtk_widget_get_window ( --> N-GObject )

Returns the widget’s window (is a GtkWindow) if it is realized, NULL otherwise.

  my Gtk::V3::Gtk::GtkButton $b .= new(:build-id<startButton>);
  my Gtk::V3::Gdk::GdkWindow $w .= new(:widget($b.get-window));
=end pod
sub gtk_widget_get_window ( N-GObject $widget )
  returns N-GObject         # GdkWindow
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_widget_] set_visible

  method gtk_widget_set_visible ( Bool $visible )

Sets the visibility state of widget. Note that setting this to TRUE doesn’t mean the widget is actually viewable, see gtk_widget_get_visible().

This function simply calls gtk_widget_show() or gtk_widget_hide() but is nicer to use when the visibility of the widget depends on some condition.
=end pod
sub gtk_widget_set_visible ( N-GObject $widget, Bool $visible) {
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_widget_] get_visible

  method gtk_widget_get_visible ( --> Bool )

Determines whether the widget is visible. If you want to take into account whether the widget’s parent is also marked as visible, use gtk_widget_is_visible() instead.

This function does not check if the widget is obscured in any way.
=end pod
sub gtk_widget_get_visible ( N-GObject $widget --> Bool ) {
  ? hidden_gtk_widget_get_visible($widget)
}
sub hidden_gtk_widget_get_visible ( N-GObject $widget )
  returns int32       # Bool 1=true
  is native(&gtk-lib)
  is symbol('gtk_widget_get_visible')
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_widget_] get_has_window

  method gtk_widget_get_has_window ( )

Specifies whether widget has a GdkWindow of its own. Note that all realized widgets have a non-NULL “window” pointer (gtk_widget_get_window() never returns a NULL window when a widget is realized), but for many of them it’s actually the GdkWindow of one of its parent widgets. Widgets that do not create a window for themselves in “realize” must announce this by calling this function with has_window = FALSE.

This function should only be called by widget implementations, and they should call it in their init() function.
=end pod
sub gtk_widget_get_has_window ( N-GObject $window --> Bool ) {
  ? hidden_gtk_widget_get_has_window($window)
}
sub hidden_gtk_widget_get_has_window ( N-GObject $window )
  returns int32
  is native(&gtk-lib)
  is symbol('gtk_widget_get_has_window')
  { * }


#TODO add a few subs more
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
#`{{
=begin pod
=head2 new

This method is not to be used.
=end pod
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkWidget';

  if ? %options<widget> || %options<build-id> {
    # provided in GObject
  }

  elsif %options.keys.elems {
    die X::GTK::V3.new(
      :message('Unsupported options for ' ~ self.^name ~
               ': ' ~ %options.keys.join(', ')
              )
    );
  }
}
}}

#-------------------------------------------------------------------------------
method fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
#note "w s0: $native-sub, ", $s;
  try { $s = &::($native-sub); }
#note "w s1: gtk_widget_$native-sub, ", $s unless ?$s;
  try { $s = &::("gtk_widget_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s
}
