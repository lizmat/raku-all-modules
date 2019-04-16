use v6;
# ==============================================================================
=begin pod

=TITLE class GTK::V3::Gtk::GtkToggleButton

=SUBTITLE

  unit class GTK::V3::Gtk::GtkToggleButton;
  also is GTK::V3::Gtk::GtkButton;

=head2 GtkToggleButton — Create buttons which retain their state

=head1 Synopsis

  my GTK::V3::Gtk::GtkToggleButton $start-tggl .= new(:label('Start Process'));

  # later in another class ...
  method start-stop-process-handle( :widget($start-tggl) ) {
    if $start-tggl.get-active {
      $start-tggl.set-label('Stop Process');
      # start process ...
    }

    else {
      $start-tggl.set-label('Start Process');
      # stop process ...
    }
  }

=end pod
# ==============================================================================
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkButton;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtktogglebutton.h
# https://developer.gnome.org/gtk3/stable/GtkToggleButton.html
unit class GTK::V3::Gtk::GtkToggleButton:auth<github:MARTIMM>;
also is GTK::V3::Gtk::GtkButton;

# ==============================================================================
=begin pod
=head1 Methods

=head2 gtk_toggle_button_new

  method gtk_toggle_button_new ( --> N-GObject )

Creates a new native toggle button object
=end pod
sub gtk_toggle_button_new ( )
  returns N-GObject
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_toggle_button_] new_with_label

  method gtk_toggle_button_new_with_label ( Str $label --> N-GObject )

Creates a new native toggle button object with a label
=end pod
sub gtk_toggle_button_new_with_label ( Str $label )
  returns N-GObject
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_toggle_button_] new_with_mnemonic

  method gtk_toggle_button_new_with_mnemonic ( Str $label --> N-GObject )

Creates a new GtkToggleButton containing a label. The label will be created using gtk_label_new_with_mnemonic(), so underscores in label indicate the mnemonic for the button.
=end pod
sub gtk_toggle_button_new_with_mnemonic ( Str $label )
  returns N-GObject # GtkWidget
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_toggle_button_] get_active

  method gtk_toggle_button_get_active ( --> Bool )

Get the button state.
=end pod
sub gtk_toggle_button_get_active ( N-GObject $w --> Bool ) {
  ? hidden_gtk_toggle_button_get_active($w);
}
sub hidden_gtk_toggle_button_get_active ( N-GObject $w )
  returns int32
  is native(&gtk-lib)
  is symbol('gtk_toggle_button_get_active')
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_toggle_button_] set_active

  method gtk_toggle_button_set_active ( Bool $active --> N-GObject )

Set the button state.
=end pod
sub gtk_toggle_button_set_active ( N-GObject $w, Bool $active ) {
  hidden-gtk_toggle_button_set_active( $w, $active ?? 1 !! 0);
}
sub hidden-gtk_toggle_button_set_active ( N-GObject $w, int32 $active )
  returns int32
  is native(&gtk-lib)
  is symbol('gtk_toggle_button_set_active')
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
=begin pod
=head2 new

  multi submethod BUILD ( Str :$label )

Create a GtkToggleButton with a label.

  multi submethod BUILD ( Bool :$empty )

Create an empty GtkToggleButton.

  multi submethod BUILD ( :$widget! )

Create a button using a native object from elsewhere. See also Gtk::V3::Glib::GObject.

  multi submethod BUILD ( Str :$build-id! )

Create a button using a native object from a builder. See also Gtk::V3::Glib::GObject.
=end pod
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkToggleButton';

  if %options<label>.defined {
    self.native-gobject(gtk_toggle_button_new_with_label(%options<text>));
  }

  elsif ? %options<empty> {
    self.native-gobject(gtk_toggle_button_new());
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
  try { $s = &::("gtk_toggle_button_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s;
}
