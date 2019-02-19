use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkContainer;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtklistbox.h
# https://developer.gnome.org/gtk3/stable/GtkListBox.html
unit class GTK::V3::Gtk::GtkListBox:auth<github:MARTIMM>
  is GTK::V3::Gtk::GtkContainer;

#-------------------------------------------------------------------------------
sub gtk_list_box_new ( )
  returns N-GObject
  is native(&gtk-lib)
  { * }

sub gtk_list_box_insert ( N-GObject $box, N-GObject $child, int32 $position)
  is native(&gtk-lib)
  { * }

# The widget in the argument list is a GtkListBox
# returned widget is a GtkListBoxRow
sub gtk_list_box_get_row_at_index ( N-GObject $box, int32 $index)
  returns N-GObject
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkListBox';

  if ? %options<empty> {
    self.native-gobject(gtk_list_box_new());
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
  try { $s = &::("gtk_list_box_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s;
}
