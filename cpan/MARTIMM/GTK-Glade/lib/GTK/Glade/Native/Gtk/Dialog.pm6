use v6;
use NativeCall;

use GTK::Glade::NativeLib;
use GTK::Glade::Native::Gtk;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtkdialog.h
# See /usr/include/gtk-3.0/gtkaboutdialog.h
unit module GTK::Glade::Native::Gtk::Dialog:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
#class GtkDialog is repr('CPointer') is export { }
#class GtkAboutDialog is repr('CPointer') is export { }

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
# gint gtk_dialog_run (GtkDialog *dialog);
# GtkResponseType is an int32
sub gtk_dialog_run ( GtkWidget $dialog )
    returns int32
    is native(&gtk-lib)
    is export
    { * }

# void gtk_dialog_response (GtkDialog *dialog, gint response_id);
sub gtk_dialog_response ( GtkWidget $dialog, int32 $response_id )
    is native(&gtk-lib)
    is export
    { * }

sub gtk_about_dialog_set_logo (
    GtkWidget $about, OpaquePointer $logo-pixbuf
    ) is native(&gtk-lib)
      is export
      { * }
