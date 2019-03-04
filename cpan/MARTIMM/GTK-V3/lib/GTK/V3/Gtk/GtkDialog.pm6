use v6;
# ==============================================================================
=begin pod

=TITLE class GTK::V3::Gtk::GtkDialog

=SUBTITLE

  unit class GTK::V3::Gtk::GtkDialog;
  also is GTK::V3::Gtk::GtkWindow;

=head1 Synopsis

  my GTK::V3::Gtk::GtkDialog $dialog .= new(:build-id<simple-dialog>);

  # show the dialog
  my Int $response = $dialog.gtk-dialog-run;
  if $response == GTK_RESPONSE_ACCEPT {
    ...
  }

=end pod
# ==============================================================================

use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkWindow;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkdialog.h
# https://developer.gnome.org/gtk3/stable/GtkDialog.html
unit class GTK::V3::Gtk::GtkDialog:auth<github:MARTIMM>;
also is GTK::V3::Gtk::GtkWindow;

# ==============================================================================
=begin pod

=head1 Types

=head2 enum GtkResponseType

Possible types of response
=begin table
  Response type | When
  ==============|================
  GTK_RESPONSE_NONE   | Returned if an action widget has no response id, or if the dialog gets programmatically hidden or destroyed
  GTK_RESPONSE_REJECT | Generic response id, not used by GTK+ dialogs
  GTK_RESPONSE_ACCEPT | Generic response id, not used by GTK+ dialogs
  GTK_RESPONSE_DELETE_EVENT | Returned if the dialog is deleted
  GTK_RESPONSE_OK     | Returned by OK buttons in GTK+ dialogs
  GTK_RESPONSE_CANCEL | Returned by Cancel buttons in GTK+ dialogs
  GTK_RESPONSE_CLOSE  | Returned by Close buttons in GTK+ dialogs
  GTK_RESPONSE_YES    | Returned by Yes buttons in GTK+ dialogs
  GTK_RESPONSE_NO     | Returned by No buttons in GTK+ dialogs
  GTK_RESPONSE_APPLY  | Returned by Apply buttons in GTK+ dialogs
  GTK_RESPONSE_HELP   | Returned by Help buttons in GTK+ dialogs
=end table
=end pod

enum GtkResponseType is export (
  GTK_RESPONSE_NONE         => -1,
  GTK_RESPONSE_REJECT       => -2,
  GTK_RESPONSE_ACCEPT       => -3,
  GTK_RESPONSE_DELETE_EVENT => -4,
  GTK_RESPONSE_OK           => -5,
  GTK_RESPONSE_CANCEL       => -6,
  GTK_RESPONSE_CLOSE        => -7,
  GTK_RESPONSE_YES          => -8,
  GTK_RESPONSE_NO           => -9,
  GTK_RESPONSE_APPLY        => -10,
  GTK_RESPONSE_HELP         => -11,
);

# ==============================================================================
=begin pod

=head1 Methods

=head2 gtk_dialog_new

Creates a new dialog box.
=end pod
sub gtk_dialog_new ( )
  returns N-GObject
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod

=head2 gtk_dialog_run

Blocks in a recursive main loop until the dialog either emits the “response” signal, or is destroyed. If the dialog is destroyed during the call to gtk_dialog_run(), gtk_dialog_run() returns GTK_RESPONSE_NONE
=end pod
sub gtk_dialog_run ( N-GObject $dialog )
  returns int32
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod

=head2 gtk_dialog_response

Emits the “response” signal with the given response ID. Used to indicate that the user has responded to the dialog in some way; typically either you or gtk_dialog_run() will be monitoring the ::response signal and take appropriate action.
=end pod
sub gtk_dialog_response ( N-GObject $dialog, int32 $response_id )
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
=begin pod
=head2 new

  multi submethod BUILD (:empty!)

Create an empty dialog

  multi submethod BUILD (:widget!)

Create a dialog using a native object from elsewhere. See also Gtk::V3::Glib::GObject.

  multi submethod BUILD (:build-id!)

Create a dialog using a native object from a builder. See also Gtk::V3::Glib::GObject.

=end pod
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkDialog';

  if ?%options<empty> {
    self.native-gobject(gtk_dialog_new);
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
  try { $s = &::("gtk_dialog_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s;
}
