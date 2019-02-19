use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkContainer;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtktextview.h
# https://developer.gnome.org/gtk3/stable/GtkTextView.html
unit class GTK::V3::Gtk::GtkTextView:auth<github:MARTIMM>
  is GTK::V3::Gtk::GtkContainer;

#-------------------------------------------------------------------------------
sub gtk_text_view_new ( )
  returns N-GObject # buffer
  is native(&gtk-lib)
  { * }

sub gtk_text_view_get_buffer ( N-GObject $view )
  returns N-GObject
  is native(&gtk-lib)
  { * }

sub gtk_text_view_set_editable ( N-GObject $widget, int32 $setting )
  is native(&gtk-lib)
  { * }

sub gtk_text_view_get_editable ( N-GObject $widget )
  returns int32
  is native(&gtk-lib)
  { * }

sub gtk_text_view_set_cursor_visible ( N-GObject $widget, int32 $setting )
  is native(&gtk-lib)
  { * }

sub gtk_text_view_get_cursor_visible ( N-GObject $widget )
  returns int32
  is native(&gtk-lib)
  { * }

sub gtk_text_view_get_monospace ( N-GObject $widget )
  returns int32
  is native(&gtk-lib)
  { * }

sub gtk_text_view_set_monospace ( N-GObject $widget, int32 $setting )
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkTextView';

  if ? %options<empty> {
    self.native-gobject(gtk_text_view_new());
  }

  elsif ? %options<widget> || ? %options<build-id> {
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
  try { $s = &::("gtk_text_view_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s;
}
