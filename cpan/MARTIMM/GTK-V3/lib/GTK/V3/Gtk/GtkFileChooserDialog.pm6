use v6;
#===============================================================================
=begin pod

=TITLE class GTK::V3::Gtk::GtkFileChooserDialog

=SUBTITLE

  unit class GTK::V3::Gtk::GtkFileChooserDialog;
  also is GTK::V3::Gtk::GtkDialog;

=head1 Synopsis

  use GTK::V3::Gtk::GtkFileChooserDialog $fchoose .= new(:empty);

  # show the dialog
  $fchoose.run;

  # when dialog buttons are pressed hide it again
  $fchoose.hide

=head1 Methods

All methods can be written with dashes or shortened by cutting the C<gtk_about_dialog_> part. This cannot be done when e.g. C<new> is left after the shortening. That would become an entirely other method. See the synopsis above for an example. Below, this is shown with brackets in the headers.
=end pod
#===============================================================================

use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkDialog;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkfilechooserdialog.h
# https://developer.gnome.org/gtk3/stable/GtkFileChooserDialog.html
unit class GTK::V3::Gtk::GtkFileChooserDialog:auth<github:MARTIMM>
  is GTK::V3::Gtk::GtkDialog;

#-------------------------------------------------------------------------------
=begin pod
=head2 gtk_about_dialog_new

  method gtk_about_dialog_new ( --> N-GObject )

Creates a new filechooser dialog widget. It returns a native object which must be stored in another object. Better, shorter and easier is to use C<.new(....)>. See info below.
=end pod
sub gtk_file_chooser_dialog_new_fc (
  Str $title, N-GObject $parent-window, int32 $file-chooser-action,
  Str $first_button_text
) returns N-GObject       # GtkFileChooserDialog
  is native(&gtk-lib)
  is symbol("gtk_file_chooser_dialog_new")
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
=begin pod
=head2 new

  multi submethod BUILD (:empty!)

Create an empty about dialog

  multi submethod BUILD (:widget!)

Create an about dialog using a native object from elsewhere. See also Gtk::V3::Glib::GObject.

  multi submethod BUILD (:build-id!)

Create an about dialog using a native object from a builder. See also Gtk::V3::Glib::GObject.

=end pod
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkAboutDialog';
#`{{
  if ? %options<title> {
    self.native-gobject(
      gtk_file_chooser_dialog_new_fc(
        %options<title>, Any,
      )
    );
  }

  elsif ? %options<widget> || %options<build-id> {
}}
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
#  try { $s = &::("gtk_file_chooser_dialog_$native-sub"); } unless ?$s;

note "ad $native-sub: ", $s;
  $s = callsame unless ?$s;

  $s;
}
