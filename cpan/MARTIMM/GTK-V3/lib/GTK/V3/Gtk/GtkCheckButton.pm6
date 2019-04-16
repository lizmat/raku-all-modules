use v6;
# ==============================================================================
=begin pod

=TITLE class GTK::V3::Gtk::GtkCheckButton

=SUBTITLE

  unit class GTK::V3::Gtk::GtkCheckButton;
  also is GTK::V3::Gtk::GtkToggleButton;

=head2 GtkCheckButton — Create widgets with a discrete toggle button

=head1 Synopsis

  my GTK::V3::Gtk::GtkCheckButton $bold-option .= new(:label<Bold>);

  # later ...
  if $bold-option.get-active {
    # Insert text in bold
  }
=end pod
# ==============================================================================
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkToggleButton;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkcheckbutton.h
# https://developer.gnome.org/gtk3/stable/GtkCheckButton.html
unit class GTK::V3::Gtk::GtkCheckButton:auth<github:MARTIMM>;
also is GTK::V3::Gtk::GtkToggleButton;

# ==============================================================================
=begin pod
=head1 Methods

=head2 gtk_check_button_new

  method gtk_check_button_new ( --> N-GObject )

Creates a new native checkbutton object
=end pod
sub gtk_check_button_new ( )
  returns N-GObject
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_check_button_] new_with_label

  method gtk_check_button_new_with_label ( Str $label --> N-GObject )

Creates a new native checkbutton object with a label
=end pod
sub gtk_check_button_new_with_label ( Str $label )
  returns N-GObject
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_check_button_] new_with_mnemonic

  method gtk_check_button_new_with_mnemonic ( Str $label --> N-GObject )

Creates a new check button containing a label. The label will be created using gtk_label_new_with_mnemonic(), so underscores in label indicate the mnemonic for the check button.
=end pod
sub gtk_check_button_new_with_mnemonic ( Str $label )
  returns N-GObject
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
=begin pod
=head2 new

  multi submethod BUILD ( Str :$label )

Create GtkCheckButton object with a label.

  multi submethod BUILD ( Bool :$empty )

Create an empty GtkCheckButton.

  multi submethod BUILD ( :$widget! )

Create a check button using a native object from elsewhere. See also Gtk::V3::Glib::GObject.

  multi submethod BUILD ( Str :$build-id! )

Create a check button using a native object from a builder. See also Gtk::V3::Glib::GObject.
=end pod
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
