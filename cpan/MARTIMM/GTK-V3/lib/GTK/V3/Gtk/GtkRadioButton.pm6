use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Glib::GSList;
use GTK::V3::Gtk::GtkCheckButton;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkradiobutton.h
# https://developer.gnome.org/gtk3/stable/GtkRadioButton.html
unit class GTK::V3::Gtk::GtkRadioButton:auth<github:MARTIMM>
  is GTK::V3::Gtk::GtkCheckButton;

#-------------------------------------------------------------------------------
sub gtk_radio_button_new ( N-GSList $group --> N-GObject )
  is native(&gtk-lib)
  { * }

sub gtk_radio_button_new_from_widget ( N-GObject $group_member --> N-GObject )
  is native(&gtk-lib)
  { * }

sub gtk_radio_button_new_with_label ( N-GSList $group, Str $label )
  returns N-GObject
  is native(&gtk-lib)
  { * }

sub gtk_radio_button_new_with_label_from_widget (
  N-GObject $group_member, Str $label
) returns N-GObject
  is native(&gtk-lib)
  { * }

sub gtk_radio_button_set_group ( N-GObject $radio_button, N-GSList $group )
  is native(&gtk-lib)
  { * }

sub gtk_radio_button_get_group ( N-GObject $radio_button )
  returns N-GSList
  is native(&gtk-lib)
  { * }

sub gtk_radio_button_join_group (
  N-GObject $radio_button, N-GObject $group_source
) returns N-GSList
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkRadioButton';

  if ? %options<empty> {
    self.native-gobject(gtk_radio_button_new(Any));
  }

  elsif ? %options<group> and ? %options<label> {
    self.native-gobject(
      gtk_radio_button_new_with_label( %options<group>, %options<label>)
    );
  }

  elsif ? %options<group-from> and ? %options<label> {
    my $w = %options<group-from>;
    $w = $w() if $w ~~ GTK::V3::Glib::GObject;
    self.native-gobject(
      gtk_radio_button_new_with_label_from_widget( $w, %options<label>)
    );
  }

  elsif ? %options<group-from> {
    my $w = %options<group-from>;
    $w = $w() if $w ~~ GTK::V3::Glib::GObject;
    self.native-gobject(gtk_radio_button_new_from_widget($w));
  }

  elsif ? %options<label> {
    self.native-gobject(gtk_radio_button_new_with_label( Any, %options<label>));
  }

  elsif ? %options<group> {
    self.native-gobject(gtk_radio_button_new(%options<group>));
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
  try { $s = &::("gtk_radio_button_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s;
}
