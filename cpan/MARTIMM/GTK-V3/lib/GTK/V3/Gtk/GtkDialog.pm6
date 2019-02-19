use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkWindow;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkdialog.h
# https://developer.gnome.org/gtk3/stable/GtkDialog.html
unit class GTK::V3::Gtk::GtkDialog:auth<github:MARTIMM>
  is GTK::V3::Gtk::GtkWindow;

#-------------------------------------------------------------------------------
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

#-------------------------------------------------------------------------------
sub gtk_dialog_new ( )
  returns N-GObject
  is native(&gtk-lib)
  { * }

# gint gtk_dialog_run (GtkDialog *dialog);
# GtkResponseType is an int32
sub gtk_dialog_run ( N-GObject $dialog )
  returns int32
  is native(&gtk-lib)
  { * }

# void gtk_dialog_response (GtkDialog *dialog, gint response_id);
sub gtk_dialog_response ( N-GObject $dialog, int32 $response_id )
  is native(&gtk-lib)
  { * }

sub gtk_about_dialog_set_logo (
  N-GObject $about, OpaquePointer $logo-pixbuf
) is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
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
