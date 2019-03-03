use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Glib::GInterface;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/gio/gfile.h
# https://developer.gnome.org/gio/stable/GFile.html
unit class GTK::V3::Glib::GFile:auth<github:MARTIMM>
  is GTK::V3::Glib::GInterface;

#-------------------------------------------------------------------------------
sub g_file_get_basename ( N-GObject $file )
  returns Str
  is native(&gtk-lib)
  { * }

sub g_file_get_path ( N-GObject $file )
  returns Str
  is native(&gtk-lib)
  { * }

sub g_file_peek_path ( N-GObject $file )
  returns Str
  is native(&gtk-lib)
  { * }

sub g_file_get_uri ( N-GObject $file )
  returns Str
  is native(&gtk-lib)
  { * }

sub g_file_get_parse_name ( N-GObject $file )
  returns Str
  is native(&gtk-lib)
  { * }

sub g_file_get_parent ( N-GObject $file )
  returns Str
  is native(&gtk-lib)
  { * }

sub g_file_has_parent ( N-GObject $file )
  returns Bool
  is native(&gtk-lib)
  { * }

#sub g_file_get_child ( N-GObject $file, Str $name )
#  returns N-GObject # GFile
#  is native(&gtk-lib)
#  { * }


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
  try { $s = &::("g_file_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s;
}
