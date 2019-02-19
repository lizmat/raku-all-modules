use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gdk::GdkScreen;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gdk/gdkscreen.h
unit class GTK::V3::Gdk::GdkDisplay:auth<github:MARTIMM>
  is GTK::V3::Glib::GObject;

#-------------------------------------------------------------------------------
sub gdk_display_open ( Str $display-name )
  returns N-GObject       # GdkDisplay
  is native(&gdk-lib)
  { * }

sub gdk_display_get_default ( )
  returns N-GObject       # GdkDisplay
  is native(&gdk-lib)
  { * }

sub gdk_display_warp_pointer (
  N-GObject $display, N-GObject $screen, int32 $x, int32 $y
) is native(&gdk-lib)
  { * }

sub gdk_display_get_name ( N-GObject $display )
  returns Str
  is native(&gdk-lib)
  { * }

#-------------------------------------------------------------------------------
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gdk::GdkDisplay';

  if ? %options<default> {
    self.native-gobject(gdk_display_get_default());
  }

  elsif ? %options<open> {
    self.native-gobject(gdk_display_open(%options<string>));
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
  try { $s = &::("gdk_display_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s
}
