use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkTextTagTable;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtktextbuffer.h
# https://developer.gnome.org/gtk3/stable/GtkTextBuffer.html
unit class GTK::V3::Gtk::GtkTextBuffer:auth<github:MARTIMM>
  is GTK::V3::Glib::GObject;

#-------------------------------------------------------------------------------
sub gtk_text_buffer_new ( N-GObject $text-tag-table )
  returns N-GObject       # GtkTextBuffer
  is native(&gtk-lib)
  { * }

sub gtk_text_buffer_get_text (
  N-GObject $buffer, CArray[int32] $start,
  CArray[int32] $end, int32 $show_hidden
) returns Str
  is native(&gtk-lib)
  { * }

sub gtk_text_buffer_get_start_iter ( N-GObject $buffer, CArray[int32] $i )
  is native(&gtk-lib)
  { * }

sub gtk_text_buffer_get_end_iter(N-GObject $buffer, CArray[int32] $i)
  is native(&gtk-lib)
  { * }

sub gtk_text_buffer_set_text(N-GObject $buffer, Str $text, int32 $len)
  is native(&gtk-lib)
  { * }

sub gtk_text_buffer_insert(
  N-GObject $buffer, CArray[int32] $start,
  Str $text, int32 $len
) is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkTextBuffer';

  if ? %options<empty> {
    my GTK::V3::Gtk::GtkTextTagTable $tag-table .= new(:empty);
    self.native-gobject(gtk_text_buffer_new($tag-table()));
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
  try { $s = &::("gtk_text_buffer_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s
}
