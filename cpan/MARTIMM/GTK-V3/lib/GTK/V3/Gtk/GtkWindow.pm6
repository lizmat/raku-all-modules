use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkBin;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkwindow.h
# https://developer.gnome.org/gtk3/stable/GtkWindow.html
unit class GTK::V3::Gtk::GtkWindow:auth<github:MARTIMM>
  is GTK::V3::Gtk::GtkBin;

#-------------------------------------------------------------------------------
enum GtkWindowPosition is export (
    GTK_WIN_POS_NONE               => 0,
    GTK_WIN_POS_CENTER             => 1,
    GTK_WIN_POS_MOUSE              => 2,
    GTK_WIN_POS_CENTER_ALWAYS      => 3,
    GTK_WIN_POS_CENTER_ON_PARENT   => 4,
);

enum GtkWindowType is export < GTK_WINDOW_TOPLEVEL GTK_WINDOW_POPUP >;

#-------------------------------------------------------------------------------
sub gtk_window_new ( int32 $window_type )
  returns N-GObject
  is native(&gtk-lib)
  { * }

sub gtk_window_set_title ( N-GObject $w, Str $title )
  returns N-GObject
  is native(&gtk-lib)
  { * }

sub gtk_window_set_position ( N-GObject $window, int32 $position )
  is native(&gtk-lib)
  { * }

sub gtk_window_set_default_size (
  N-GObject $window, int32 $width, int32 $height
) is native(&gtk-lib)
  { * }

# void gtk_window_set_modal (GtkWindow *window, gboolean modal);
# can be set in glade
sub gtk_window_set_modal ( N-GObject $window, Bool $modal )
  is native(&gtk-lib)
  { * }

# void gtk_window_set_transient_for ( GtkWindow *window, GtkWindow *parent);
sub gtk_window_set_transient_for ( N-GObject $window, N-GObject $parent )
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkWindow';

  if ?%options<empty> and
     ?%options<window-type> and
     %options<window-type> ~~ GtkWindowType {

    self.native-gobject(gtk_window_new(%options<window-type>));
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
