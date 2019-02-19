use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtktexttagtable.h
# https://developer.gnome.org/gtk3/stable/GtkTextTagTable.html
unit class GTK::V3::Gtk::GtkTextTagTable:auth<github:MARTIMM>
  is GTK::V3::Glib::GObject;

#-------------------------------------------------------------------------------
sub gtk_text_tag_table_new ( )
  returns N-GObject         # GtkTextTagTable
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkTextTagTable';

  if ? %options<empty> {
    self.native-gobject(gtk_text_tag_table_new());
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
  try { $s = &::("gtk_text_tag_table_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s
}
