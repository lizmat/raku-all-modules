use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Glib::GInterface;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/gio/gfile.h
# https://developer.gnome.org/gtk3/stable/GFile.html
unit class GTK::V3::Glib::GFile:auth<github:MARTIMM>
  is GTK::V3::Glib::GInterface;

#-------------------------------------------------------------------------------

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Glib::GFile';

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
  try { $s = &::("gtk_bin_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s;
}
