use v6;
use NativeCall;

use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkMain;
use GTK::V3::Gtk::GtkWidget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtklabel.h
# https://developer.gnome.org/gtk3/stable/GtkLabel.html
unit class GTK::V3::Gtk::GtkLabel:auth<github:MARTIMM>
  is GTK::V3::Gtk::GtkWidget;

#-------------------------------------------------------------------------------
sub gtk_label_new ( Str $text )
  returns N-GObject
  is native(&gtk-lib)
  { * }

sub gtk_label_get_text ( N-GObject $label )
  returns Str
  is native(&gtk-lib)
  { * }

sub gtk_label_set_text ( N-GObject $label, Str $str )
  is native(&gtk-lib)
  { * }

sub gtk_label_new_with_mnemonic ( Str $mnem )
  returns N-GObject
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkLabel';

  if %options<label>.defined {
    self.native-gobject(gtk_label_new(%options<label>));
  }

  elsif ? %options<mnemonic> {
    self.native-gobject(gtk_label_new_with_mnemonic(%options<mnemonic>));
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
  try { $s = &::("gtk_label_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s
}
