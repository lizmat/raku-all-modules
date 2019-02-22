use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;

#-------------------------------------------------------------------------------
# No documentation, only from object hierarchy
# https://developer.gnome.org/gtk3/stable/ch02.html
unit class GTK::V3::Glib::GInitiallyUnowned:auth<github:MARTIMM>
  is GTK::V3::Glib::GObject;

#-------------------------------------------------------------------------------
# No subs implemented. Just setup for hierargy.
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Glib::GInitiallyUnowned';
  die X::GTK::V3.new(:message('Forbidden to initialize for ' ~ self.^name));
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
