use v6;
# ==============================================================================
=begin pod

=TITLE class GTK::V3::Gtk::GtkComboBoxText

=SUBTITLE

  unit class GTK::V3::Gtk::GtkComboBoxText;
  also is GTK::V3::Gtk::GtkComboBox;

=head2 GtkComboBoxText — A simple, text-only combo box

=head1 Synopsis

  # Get a fully designed text combobox
  my GTK::V3::Gtk::GtkComboBoxText $server-cb .= new(:build-id<serverComboBox>);
  my Str $server = $server-cb.get-active-id;

=end pod
# ==============================================================================
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkComboBox;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkcombobox.h
# https://developer.gnome.org/gtk3/stable/GtkComboBox.html
unit class GTK::V3::Gtk::GtkComboBoxText:auth<github:MARTIMM>;
also is GTK::V3::Gtk::GtkComboBox;

# ==============================================================================
=begin pod

=head1 Methods

=head2 gtk_combo_box_text_append

  method gtk_combo_box_text_append ( Str $id, Str $text )

Appends text. See also L<gnome developer docs| https://developer.gnome.org/gtk3/stable/GtkComboBoxText.html#gtk-combo-box-text-append>.
=end pod
sub gtk_combo_box_text_append ( N-GObject $combo_box, Str $id, Str $text )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod

=head2 gtk_combo_box_text_prepend

  method gtk_combo_box_text_prepend ( Str $id, Str $text )

Prepends text. See also L<gnome developer docs|https://developer.gnome.org/gtk3/stable/GtkComboBoxText.html#gtk-combo-box-text-prepend>.

This is the same as calling gtk_combo_box_text_insert() with a position of 0.
=end pod
sub gtk_combo_box_text_prepend ( N-GObject $combo_box, Str $id, Str $text )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod

=head2 gtk_combo_box_text_insert

  method gtk_combo_box_text_insert ( Int $position, Str $id, Str $text )

Insert text at position. See also L<gnome developer docs|https://developer.gnome.org/gtk3/stable/GtkComboBoxText.html#gtk-combo-box-text-insert>.
=end pod
sub gtk_combo_box_text_insert (
  N-GObject $combo_box, int32 $position, Str $id, Str $text
) is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod

=head2 [gtk_combo_box_text_] append_text

  method gtk_combo_box_text_append_text ( Str $text )

Append text. See also L<gnome developer docs|https://developer.gnome.org/gtk3/stable/GtkComboBoxText.html#gtk-combo-box-text-append-text>.
=end pod
sub gtk_combo_box_text_append_text ( N-GObject $combo_box, Str $text )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod

=head2 [gtk_combo_box_text_] prepend_text

  method gtk_combo_box_text_prepend_text ( Str $text )

Prepend text. See also L<gnome developer docs|https://developer.gnome.org/gtk3/stable/GtkComboBoxText.html#gtk-combo-box-text-prepend-text>.
=end pod
sub gtk_combo_box_text_prepend_text ( N-GObject $combo_box, Str $text )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod

=head2 [gtk_combo_box_text_] insert_text

  method gtk_combo_box_text_insert_text ( int32 $position, Str $text )

Insert text at position. See also L<gnome developer docs|https://developer.gnome.org/gtk3/stable/GtkComboBoxText.html#gtk-combo-box-text-insert-text>.
=end pod
sub gtk_combo_box_text_insert_text (
  N-GObject $combo_box, int32 $position, Str $text
) is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod

=head2 gtk_combo_box_text_remove

  method gtk_combo_box_text_remove ( Int $position )

Remove text at position. See also L<gnome developer docs|https://developer.gnome.org/gtk3/stable/GtkComboBoxText.html#gtk-combo-box-text-remove>.
=end pod
sub gtk_combo_box_text_remove ( N-GObject $combo_box, int32 $position )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod

=head2 [gtk_combo_box_text_] remove_all

  method gtk_combo_box_text_remove_all ( )

Remove all text entries. See also L<gnome developer docs|https://developer.gnome.org/gtk3/stable/GtkComboBoxText.html#gtk-combo-box-text-remove-all>.
=end pod
sub gtk_combo_box_text_remove_all ( N-GObject $combo_box )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod

=head2 gtk_combo_box_text_get_active_text

  method gtk_combo_box_text_get_active_text ( )

Get selected entry. See also L<gnome developer docs|https://developer.gnome.org/gtk3/stable/GtkComboBoxText.html#gtk-combo-box-text-get-active-text>.
=end pod
sub gtk_combo_box_text_get_active_text ( N-GObject $combo_box )
  returns Str
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
=begin pod
=head2 new

  multi submethod BUILD ( :$widget! )

Create a simple text combobox using a native object from elsewhere. See also Gtk::V3::Glib::GObject.

  multi submethod BUILD ( Str :$build-id! )

Create a simple text combobox using a native object from a builder. See also Gtk::V3::Glib::GObject.

=end pod
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkComboBoxText';

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
  try { $s = &::("gtk_combo_box_text_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s;
}
