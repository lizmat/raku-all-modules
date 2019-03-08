use v6;
# ==============================================================================
=begin pod

=TITLE class GTK::V3::Gtk::GtkComboBox

=SUBTITLE

  unit class GTK::V3::Gtk::GtkComboBox;
  also is GTK::V3::Gtk::GtkBin;

=head1 Synopsis

  # Get a fully designed combobox
  my GTK::V3::Gtk::GtkComboBox $server-cb .= new(:build-id<serverComboBox>);
  my Str $server = $server-cb.get-active-id;
=end pod
# ==============================================================================
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkBin;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkcombobox.h
# https://developer.gnome.org/gtk3/stable/GtkComboBox.html
unit class GTK::V3::Gtk::GtkComboBox:auth<github:MARTIMM>;
also is GTK::V3::Gtk::GtkBin;

# ==============================================================================
=begin pod

=head1 Methods

=head2 [gtk_combo_box_] get_active

  method gtk_combo_box_get_active ( --> int32 )

Returns the index of the currently active item, or -1 if there’s no active item. See also L<gnome developer docs|https://developer.gnome.org/gtk3/stable/GtkComboBox.html#gtk-combo-box-get-active>.
=end pod
sub gtk_combo_box_get_active ( N-GObject $combo_box )
  returns int32
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod

=head2 [gtk_combo_box_] set_active

  method gtk_combo_box_set_active ( int32 $index )

Sets the active item of combo_box to be the item at index. See also L<gnome developer docs|https://developer.gnome.org/gtk3/stable/GtkComboBox.html#gtk-combo-box-set-active>.
=end pod
sub gtk_combo_box_set_active ( N-GObject $combo_box, int32 $index )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod

=head2 [gtk_combo_box_] get_active_id

  method gtk_combo_box_get_active_id ( --> Str )

Returns the ID of the active row of combo_box. See also L<gnome developer docs|https://developer.gnome.org/gtk3/stable/GtkComboBox.html#gtk-combo-box-get-active-id>.
=end pod
sub gtk_combo_box_get_active_id ( N-GObject $combo_box )
  returns Str
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod

=head2 [gtk_combo_box_] set_active_id

  method gtk_combo_box_set_active_id ( Str $active_id )

Changes the active row of combo_box. See also L<gnome developer docs|https://developer.gnome.org/gtk3/stable/GtkComboBox.html#gtk-combo-box-set-active-id>.
=end pod
sub gtk_combo_box_set_active_id ( N-GObject $combo_box, Str $active_id )
  returns int32 # Bool
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
=begin pod
=head2 new

  multi submethod BUILD (:widget!)

Create a combobox using a native object from elsewhere. See also Gtk::V3::Glib::GObject.

  multi submethod BUILD (:build-id!)

Create a combobox using a native object from a builder. See also Gtk::V3::Glib::GObject.

=end pod
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkComboBox';

  if ? %options<widget> || %options<build-id> {
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
  try { $s = &::("gtk_combo_box_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s;
}
