use v6;
# ==============================================================================
=begin pod

=TITLE class GTK::V3::Gtk::GtkButton

=SUBTITLE

  unit class GTK::V3::Gtk::GtkButton;
  also is GTK::V3::Gtk::GtkBin;

=head2 GtkButton — A widget that emits a signal when clicked on

=head1 Synopsis

  my GTK::V3::Gtk::GtkButton $start-button .= new(:label<Start>);
=end pod
# ==============================================================================
use NativeCall;

use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkBin;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkbutton.h
# https://developer.gnome.org/gtk3/stable/GtkButton.html
unit class GTK::V3::Gtk::GtkButton:auth<github:MARTIMM>;
also is GTK::V3::Gtk::GtkBin;

# ==============================================================================
=begin pod
=head1 Methods

=head2 gtk_button_new

  method gtk_button_new ( --> N-GObject )

Creates a new native button object
=end pod
sub gtk_button_new ( )
  returns N-GObject
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_button_] new_with_label

  method gtk_button_new_with_label ( Str $label --> N-GObject )

Creates a new native button object with a label
=end pod
sub gtk_button_new_with_label ( Str $label )
  returns N-GObject
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_button_] get_label

  method gtk_button_get_label ( --> Str )

Get text label of button
=end pod
sub gtk_button_get_label ( N-GObject $widget )
  returns Str
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_button_] set_label

  method gtk_button_set_label ( Str $label )

Set a label ob the button
=end pod
sub gtk_button_set_label ( N-GObject $widget, Str $label )
  is native(&gtk-lib)
  { * }

#TODO can add a few more subs

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
=begin pod
=head2 new

  multi submethod BUILD ( Str :$label )

Creates a new button object with a label

  multi submethod BUILD ( Bool :$empty )

Create an empty button

  multi submethod BUILD ( :$widget! )

Create a button using a native object from elsewhere. See also Gtk::V3::Glib::GObject.

  multi submethod BUILD ( Str :$build-id! )

Create a button using a native object from a builder. See also Gtk::V3::Glib::GObject.
=end pod
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkButton';

  if %options<label>.defined {
    self.native-gobject(gtk_button_new_with_label(%options<label>));
  }

  elsif ? %options<empty> {
    self.native-gobject(gtk_button_new());
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
  try { $s = &::("gtk_button_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s
}
