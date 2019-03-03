use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::Glib::GObject;
use GTK::V3::N::NativeLib;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gdk/gdkscreen.h
# https://developer.gnome.org/gdk3/stable/GdkScreen.html
unit class GTK::V3::Gdk::GdkScreen:auth<github:MARTIMM>
  is GTK::V3::Glib::GObject;

#-------------------------------------------------------------------------------
sub gdk_screen_get_default ( )
  returns N-GObject         # GdkScreen
  is native(&gdk-lib)
  { * }

sub gdk_screen_get_display ( N-GObject $screen )
  returns N-GObject         # GdkDisplay
  is native(&gdk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gdk::GdkScreen';

  if ? %options<default> {
    self.native-gobject(gdk_screen_get_default());
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
  try { $s = &::("gdk_screen_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s
}
