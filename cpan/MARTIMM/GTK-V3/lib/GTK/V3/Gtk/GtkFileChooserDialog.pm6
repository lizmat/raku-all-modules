use v6;
# ==============================================================================
=begin pod

=TITLE class GTK::V3::Gtk::GtkFileChooserDialog

=SUBTITLE

  unit class GTK::V3::Gtk::GtkFileChooserDialog;
  also is GTK::V3::Gtk::GtkDialog;

=head1 Synopsis

  use GTK::V3::Gtk::GtkDialog;
  use GTK::V3::Gtk::GtkFileChooserDialog;

  my GTK::V3::Gtk::GtkFileChooserDialog $fchoose .= new(:build-id<save-dialog>);

  # show the dialog
  my Int $response = $fchoose.gtk-dialog-run;
  if $response == GTK_RESPONSE_ACCEPT {
    ...
  }

  # when dialog buttons are pressed hide it again
  $fchoose.hide;

=end pod
# ==============================================================================

use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkDialog;
use GTK::V3::Gtk::GtkFileChooser;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkfilechooserdialog.h
# https://developer.gnome.org/gtk3/stable/GtkFileChooserDialog.html
unit class GTK::V3::Gtk::GtkFileChooserDialog:auth<github:MARTIMM>;
also is GTK::V3::Gtk::GtkDialog;

# ==============================================================================
=begin pod

=head1 Methods

=head2 [gtk_file_chooser_] dialog_new_two_buttons

  method gtk_file_chooser_dialog_new_two_buttons (
    Str $title, N-GObject $parent-window, int32 $file-chooser-action,
    Str $first_button_text, int32 $first-button-response,
    Str $secnd-button-text, int32 $secnd-button-response,
    OpaquePointer $stopper
    --> N-GObject
  )

Creates a new filechooser dialog widget. It returns a native object which must be stored in another object. Better, shorter and easier is to use C<.new(....)>. See info below.
=end pod
sub gtk_file_chooser_dialog_new_two_buttons (
  Str $title, N-GObject $parent-window, int32 $file-chooser-action,
  Str $first-button-text, int32 $first-button-response,
  Str $secnd-button-text, int32 $secnd-button-response,
  OpaquePointer $stopper
) returns N-GObject       # GtkFileChooserDialog
  is native(&gtk-lib)
  is symbol("gtk_file_chooser_dialog_new")
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
=begin pod
=head2 new

  multi submethod BUILD (:title!)

Create a filechooser dialog with given title. There will be only two buttons
C<:bt1text> and C<:bt2text>. These are by default C<Cancel> and C<Accept>.
There response types are given by  C<:bt1response> and C<:bt2response>.
Defaults for these are C<GTK_RESPONSE_CANCEL> and C<GTK_RESPONSE_ACCEPT>
respectively.

The filechooser action is set with C<:action> which has C<GTK_FILE_CHOOSER_ACTION_OPEN> as its default.

The parent window is set by C<:window> and is by default C<Any>.

The values are defined in C<GTK::V3::Gtk::GtkDialog> and C<GtkFileChooser>.

  multi submethod BUILD (:widget!)

Create a filechooser dialog using a native object from elsewhere. See also Gtk::V3::Glib::GObject.

  multi submethod BUILD (:build-id!)

Create a filechooser dialog using a native object from a builder. See also Gtk::V3::Glib::GObject.

=end pod
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkFileChooserDialog';

  if ? %options<title> {
    self.native-gobject(
      gtk_file_chooser_dialog_new_two_buttons(
        %options<title>, %options<window>//Any,
        %options<action>//GTK_FILE_CHOOSER_ACTION_OPEN,
        %options<bt1text>//'Cancel',
        %options<bt1response>//GTK_RESPONSE_CANCEL,
        %options<bt2text>//'Accept',
        %options<bt2response>//GTK_RESPONSE_ACCEPT,
        Any
      )
    );
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
#  try { $s = &::("gtk_file_chooser_dialog_$native-sub"); } unless ?$s;

#note "ad $native-sub: ", $s;
  $s = callsame unless ?$s;

  $s;
}
