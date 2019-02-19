use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gdk::GdkScreen;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkcssprovider.h
# https://developer.gnome.org/gtk3/stable/GtkCssProvider.html
unit class GTK::V3::Gtk::GtkCssProvider:auth<github:MARTIMM>
  is GTK::V3::Glib::GObject;

#-------------------------------------------------------------------------------
sub gtk_css_provider_new ( )
  returns N-GObject       # GtkCssProvider
  is native(&gtk-lib)
  { * }

sub gtk_css_provider_get_named ( Str $name, Str $variant )
  returns N-GObject
  is native(&gtk-lib)
  { * }

sub gtk_css_provider_load_from_path (
  N-GObject $css_provider, Str $css-file, OpaquePointer
) is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkCssProvider';

  if ? %options<empty> {
    self.native-gobject(gtk_css_provider_new());
  }

  elsif ? %options<widget> || ? %options<build-id> {
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
  try { $s = &::("gtk_css_provider_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s
}
