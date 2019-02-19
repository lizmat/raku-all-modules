use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkDialog;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkaboutdialog.h
# https://developer.gnome.org/gtk3/stable/GtkAboutDialog.html
unit class GTK::V3::Gtk::GtkAboutDialog:auth<github:MARTIMM>
  is GTK::V3::Gtk::GtkDialog;

#-------------------------------------------------------------------------------
sub gtk_about_dialog_new ( )
  returns N-GObject       # GtkAboutDialog
  is native(&gtk-lib)
  { * }

sub gtk_about_dialog_get_program_name ( N-GObject $dialog )
  returns Str
  is native(&gtk-lib)
  { * }

sub gtk_about_dialog_set_program_name ( N-GObject $dialog, Str $pname )
  is native(&gtk-lib)
  { * }

sub gtk_about_dialog_get_version ( N-GObject $dialog )
  returns Str
  is native(&gtk-lib)
  { * }

sub gtk_about_dialog_set_version ( N-GObject $dialog, Str $version )
  is native(&gtk-lib)
  { * }

#TODO some more subs

sub gtk_about_dialog_set_logo ( N-GObject $dialog, OpaquePointer $logo-pixbuf )
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkAboutDialog';

  if ? %options<empty> {
    self.native-gobject(gtk_about_dialog_new());
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
  try { $s = &::("gtk_about_dialog_$native-sub"); } unless ?$s;

note "ad $native-sub: ", $s;
  $s = callsame unless ?$s;

  $s;
}
