use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GBoxed;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/glib/gvalue.h
# https://developer.gnome.org/gobject/stable/gobject-Generic-values.html
# /usr/include/glib-2.0/glib/gvaluetypes.h
# https://developer.gnome.org/gobject/stable/gobject-Standard-Parameter-and-Value-Types.html

unit class GTK::V3::Glib::GValue:auth<github:MARTIMM>;
also is GTK::V3::Glib::GBoxed;

#-------------------------------------------------------------------------------
class N-GValue is repr('CStruct') is export {
  has int32 $!g-type;

  # Data should be a union. We do not use it but GTK does so here it is
  # only set to a type with 64 bits for the longest field in the union.
  has int64 $!g-data;

  submethod TWEAK {
    $!g-type = 0;
    $!g-data = 0;
  }
}

#-------------------------------------------------------------------------------
sub g_value_init ( N-GValue $value, int32 $g_type )
  returns N-GValue # GValue *
  is native(&gobject-lib)
  { * }

sub g_value_reset ( N-GValue $value )
  returns N-GValue # GValue *
  is native(&gobject-lib)
  { * }

sub g_value_unset ( N-GValue $value )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
sub g_value_set_boolean ( N-GValue $value, int32 $boolean )
  is native(&gobject-lib)
  { * }

sub g_value_get_boolean ( N-GValue $value )
  returns int32 # bool
  is native(&gobject-lib)
  { * }

sub g_value_set_int ( N-GValue $value, int32 $v_int )
  is native(&gobject-lib)
  { * }

sub g_value_get_int ( N-GValue $value )
  returns int32
  is native(&gobject-lib)
  { * }

sub g_value_set_uint ( N-GValue $value, uint32 $v_int )
  is native(&gobject-lib)
  { * }

sub g_value_get_uint ( N-GValue $value )
  returns uint32
  is native(&gobject-lib)
  { * }

sub g_value_set_long ( N-GValue $value, int32 $v_int )
  is native(&gobject-lib)
  { * }

sub g_value_get_long ( N-GValue $value )
  returns int32
  is native(&gobject-lib)
  { * }

sub g_value_set_ulong ( N-GValue $value, uint32 $v_int )
  is native(&gobject-lib)
  { * }

sub g_value_get_ulong ( N-GValue $value )
  returns uint32
  is native(&gobject-lib)
  { * }

sub g_value_set_int64g ( N-GValue $value, int64 $v_int )
  is native(&gobject-lib)
  { * }

sub g_value_get_int64 ( N-GValue $value )
  returns int64
  is native(&gobject-lib)
  { * }

sub g_value_set_uint64g ( N-GValue $value, uint64 $v_int )
  is native(&gobject-lib)
  { * }

sub g_value_get_uint64 ( N-GValue $value )
  returns uint64
  is native(&gobject-lib)
  { * }

sub g_value_set_float ( N-GValue $value, num32 $v_float )
  is native(&gobject-lib)
  { * }

sub g_value_get_float ( N-GValue $value )
  returns num32
  is native(&gobject-lib)
  { * }

sub g_value_set_double ( N-GValue $value, num64 $v_double )
  is native(&gobject-lib)
  { * }

sub g_value_get_double ( N-GValue $value )
  returns num64
  is native(&gobject-lib)
  { * }

sub g_value_set_enum ( N-GValue $value, int32 $v_enum )
  is native(&gobject-lib)
  { * }

sub g_value_get_enum ( N-GValue $value )
  returns int32
  is native(&gobject-lib)
  { * }

sub g_value_set_flags ( N-GValue $value, uint32 $v_flags )
  is native(&gobject-lib)
  { * }

sub g_value_get_flags ( N-GValue $value )
  returns uint32
  is native(&gobject-lib)
  { * }

sub g_value_set_string ( N-GValue $value, Str $v_string )
  is native(&gobject-lib)
  { * }

sub g_value_get_string ( N-GValue $value )
  returns Str
  is native(&gobject-lib)
  { * }

sub g_value_get_gtype ( N-GValue $value )
  returns int32 # GType
  is native(&gobject-lib)
  { * }

sub g_value_set_gtype ( N-GValue $value, int32 $v_gtype )
  is native(&gobject-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Glib::GValue';

  if ? %options<init> {
    self.native-gboxed(g_value_init( N-GValue.new, %options<init>));
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
method fallback ( $native-sub, |c ) {

  my Callable $s;
  try { $s = &::($native-sub); }
  try { $s = &::("g_value_$native-sub"); } unless ?$s;

  $s
}
