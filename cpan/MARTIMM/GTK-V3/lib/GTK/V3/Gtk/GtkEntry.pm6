use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkMisc;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkentry.h
# https://developer.gnome.org/gtk3/stable/GtkEntry.html
unit class GTK::V3::Gtk::GtkEntry:auth<github:MARTIMM>
  is GTK::V3::Gtk::GtkMisc;

#-------------------------------------------------------------------------------
sub gtk_entry_new ( )
  returns N-GObject
  is native(&gtk-lib)
  { * }

sub gtk_entry_get_text ( N-GObject $entry )
  returns Str
  is native(&gtk-lib)
  { * }

sub gtk_entry_set_text ( N-GObject $entry, Str $text )
  is native(&gtk-lib)
  { * }

sub gtk_entry_set_visibility ( N-GObject $entry, Bool $visible )
  is native(&gtk-lib)
  { * }

# hints is an enum with type GtkInputHints -> int
# The values are defined in Enums.pm6
sub gtk_entry_set_input_hints ( N-GObject $entry, uint32 $hints )
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
#submethod BUILD ( ) {
#  self.native-gobject(gtk_entry_new);
#}
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkEntry';

  if ? %options<empty> {
    self.native-gobject(gtk_entry_new());
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
  try { $s = &::("gtk_entry_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s;
}
