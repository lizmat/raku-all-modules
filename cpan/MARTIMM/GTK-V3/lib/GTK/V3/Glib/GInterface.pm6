use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/gobject/gtypemodule.h
# https://developer.gnome.org/gobject/stable/GTypeModule.html
unit class GTK::V3::Glib::GInterface:auth<github:MARTIMM>
  is GTK::V3::Glib::GObject;

#-------------------------------------------------------------------------------
# No subs implemented. Just setup for hierargy.
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Glib::GInterface';

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

#  my Callable $s;
#  try { $s = &::($native-sub); }
#  try { $s = &::("g_type_module_$native-sub"); } unless ?$s;

#  $s = callsame unless ?$s;

  my Callable $s = callsame;
  $s;
}
