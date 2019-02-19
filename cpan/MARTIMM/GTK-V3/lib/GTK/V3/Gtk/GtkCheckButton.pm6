use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkToggleButton;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkcheckbutton.h
# https://developer.gnome.org/gtk3/stable/GtkCheckButton.html
unit class GTK::V3::Gtk::GtkCheckButton:auth<github:MARTIMM>
  is GTK::V3::Gtk::GtkToggleButton;

#-------------------------------------------------------------------------------
sub gtk_check_button_new ( )
  returns N-GObject
  is native(&gtk-lib)
  { * }

sub gtk_check_button_new_with_label ( Str $label )
  returns N-GObject
  is native(&gtk-lib)
  { * }

sub gtk_check_button_new_with_mnemonic ( Str $label )
  returns N-GObject
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkCheckButton';

  if %options<label>.defined {
    self.native-gobject(gtk_check_button_new_with_label(%options<label>));
  }

  elsif ? %options<empty> {
    self.native-gobject(gtk_check_button_new());
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
  try { $s = &::("gtk_check_button_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s;
}
