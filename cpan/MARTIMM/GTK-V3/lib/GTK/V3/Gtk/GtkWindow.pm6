use v6;
# ==============================================================================
=begin pod

=TITLE class GTK::V3::Gtk::GtkWindow

=SUBTITLE

  unit class GTK::V3::Gtk::GtkWindow;
  also is GTK::V3::Gtk::GtkBin;

=head2 GtkWindow — Toplevel which can contain other widgets

See readme for an example.

=end pod
# ==============================================================================
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkBin;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkwindow.h
# https://developer.gnome.org/gtk3/stable/GtkWindow.html
unit class GTK::V3::Gtk::GtkWindow:auth<github:MARTIMM>;
also is GTK::V3::Gtk::GtkBin;

# ==============================================================================
=begin pod
=head1 Enums

=head2 GtkWindowPosition

Window placement can be influenced using this enumeration. Note that using GTK_WIN_POS_CENTER_ALWAYS is almost always a bad idea. It won’t necessarily work well with all window managers or on all windowing systems.

=item GTK_WIN_POS_NONE. No influence is made on placement.
=item GTK_WIN_POS_CENTER. Windows should be placed in the center of the screen.
=item GTK_WIN_POS_MOUSE. Windows should be placed at the current mouse position.
=item GTK_WIN_POS_CENTER_ALWAYS. Keep window centered as it changes size, etc.
=item GTK_WIN_POS_CENTER_PARENT. Center the window on its transient parent.

=end pod
enum GtkWindowPosition is export (
    GTK_WIN_POS_NONE               => 0,
    GTK_WIN_POS_CENTER             => 1,
    GTK_WIN_POS_MOUSE              => 2,
    GTK_WIN_POS_CENTER_ALWAYS      => 3,
    GTK_WIN_POS_CENTER_ON_PARENT   => 4,
);

#-------------------------------------------------------------------------------
=begin pod
=head2 GtkWindowType

A GtkWindow can be one of these types. Most things you’d consider a “window” should have type GTK_WINDOW_TOPLEVEL; windows with this type are managed by the window manager and have a frame by default (call gtk_window_set_decorated() to toggle the frame). Windows with type GTK_WINDOW_POPUP are ignored by the window manager; window manager keybindings won’t work on them, the window manager won’t decorate the window with a frame, many GTK+ features that rely on the window manager will not work (e.g. resize grips and maximization/minimization). GTK_WINDOW_POPUP is used to implement widgets such as GtkMenu or tooltips that you normally don’t think of as windows per se. Nearly all windows should be GTK_WINDOW_TOPLEVEL. In particular, do not use GTK_WINDOW_POPUP just to turn off the window borders; use gtk_window_set_decorated() for that.

=item GTK_WINDOW_TOPLEVEL. A regular window, such as a dialog.
=item GTK_WINDOW_POPUP. A special window such as a tooltip.

=end pod
enum GtkWindowType is export < GTK_WINDOW_TOPLEVEL GTK_WINDOW_POPUP >;

# ==============================================================================
=begin pod
=head1 Methods
=head2 gtk_window_new

  method gtk_window_new ( GtkWindowType $type )

Creates a new GtkWindow, which is a toplevel window that can contain other widgets. Nearly always, the type of the window should be GTK_WINDOW_TOPLEVEL. If you’re implementing something like a popup menu from scratch (which is a bad idea, just use GtkMenu), you might use GTK_WINDOW_POPUP. GTK_WINDOW_POPUP is not for dialogs, though in some other toolkits dialogs are called “popups”. In GTK+, GTK_WINDOW_POPUP means a pop-up menu or pop-up tooltip. On X11, popup windows are not controlled by the window manager.

If you simply want an undecorated window (no window borders), use gtk_window_set_decorated(), don’t use GTK_WINDOW_POPUP.

All top-level windows created by gtk_window_new() are stored in an internal top-level window list. This list can be obtained from gtk_window_list_toplevels(). Due to Gtk+ keeping a reference to the window internally, gtk_window_new() does not return a reference to the caller.

To delete a GtkWindow, call gtk_widget_destroy().
=end pod
sub gtk_window_new ( int32 $window_type )
  returns N-GObject
  is native(&gtk-lib)
  { * }

#-------------------------------------------------------------------------------
=begin pod
=head2 [gtk_window_] set_title

  method gtk_window_set_title ( Str $title )

Sets the title of the GtkWindow. The title of a window will be displayed in its title bar; on the X Window System, the title bar is rendered by the window manager, so exactly how the title appears to users may vary according to a user’s exact configuration. The title should help a user distinguish this window from other windows they may have open. A good title might include the application name and current document filename, for example.
=end pod
sub gtk_window_set_title ( N-GObject $w, Str $title )
  returns N-GObject
  is native(&gtk-lib)
  { * }

#-------------------------------------------------------------------------------
=begin pod
=head2 [gtk_window_] set_default_size

  method gtk_window_set_default_size ( Int $width, Int $height )

Sets the default size of a window. See also L<the developer docs|https://developer.gnome.org/gtk3/stable/GtkWindow.html#gtk-window-set-default-size>.
=end pod
sub gtk_window_set_default_size (
  N-GObject $window, int32 $width, int32 $height
) is native(&gtk-lib)
  { * }

#-------------------------------------------------------------------------------
=begin pod
=head2 [gtk_window_] set_modal

  method gtk_window_set_modal ( Bool $modal )

Sets a window modal or non-modal. Modal windows prevent interaction with other windows in the same application. To keep modal dialogs on top of main application windows, use gtk_window_set_transient_for() to make the dialog transient for the parent; most window managers will then disallow lowering the dialog below the parent.
=end pod
sub gtk_window_set_modal ( N-GObject $window, Bool $modal )
  is native(&gtk-lib)
  { * }

#-------------------------------------------------------------------------------
=begin pod
=head2 [gtk_window_] set_position

  method gtk_window_set_position ( Int $position )

Sets a position constraint for this window. If the old or new constraint is GTK_WIN_POS_CENTER_ALWAYS, this will also cause the window to be repositioned to satisfy the new constraint.
=end pod
sub gtk_window_set_position ( N-GObject $window, int32 $position )
  is native(&gtk-lib)
  { * }

#-------------------------------------------------------------------------------
=begin pod
=head2 [gtk_window_] set_transient_for

  method gtk_window_set_transient_for ( GTK::V3::Glib::GObject $main-window )

Dialog windows should be set transient for the main application window they were spawned from. This allows window managers to e.g. keep the dialog on top of the main window, or center the dialog over the main window.
=end pod
sub gtk_window_set_transient_for ( N-GObject $window, N-GObject $parent )
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
=begin pod
=head2 new

  multi submethod BUILD (
    Bool :$empty!, GtkWindowType :$window-type = GTK_WINDOW_TOPLEVEL
  )

Create an empty top level window or popup.

  multi submethod BUILD ( :$widget! )

Create a button using a native object from elsewhere. See also Gtk::V3::Glib::GObject.

  multi submethod BUILD ( Str :$build-id! )

Create a button using a native object from a builder. See also Gtk::V3::Glib::GObject.

=end pod
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkWindow';

  if ?%options<empty> {
    if ? %options<window-type> and %options<window-type> ~~ GtkWindowType {
      self.native-gobject(gtk_window_new(%options<window-type>));
    }

    else {
      self.native-gobject(gtk_window_new(GTK_WINDOW_TOPLEVEL);
    }
  }

  elsif ? %options<widget> || %options<build-id> {
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

#-------------------------------------------------------------------------------
method fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::($native-sub); }
  try { $s = &::("gtk_window_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s;
}
