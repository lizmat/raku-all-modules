use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GValue;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/gtypes.h
# https://developer.gnome.org/gobject/stable/gobject-Type-Information.html
# https://developer.gnome.org/glib/stable/glib-Basic-Types.html
unit class GTK::V3::Glib::GType:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
#define	G_TYPE_FUNDAMENTAL_SHIFT (2)
constant G_TYPE_FUNDAMENTAL_SHIFT = 2;

#define	G_TYPE_FUNDAMENTAL_MAX		(255 << G_TYPE_FUNDAMENTAL_SHIFT)
sub G_TYPE_MAKE_FUNDAMENTAL_MAX ( --> int32) {
  255 +< G_TYPE_FUNDAMENTAL_SHIFT;
}

#define G_TYPE_INVALID G_TYPE_MAKE_FUNDAMENTAL (0)
constant G_TYPE_INVALID is export = 0 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_NONE G_TYPE_MAKE_FUNDAMENTAL (1)
constant G_TYPE_NONE is export = 1 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_INTERFACE G_TYPE_MAKE_FUNDAMENTAL (2)
constant G_TYPE_INTERFACE is export = 2 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_CHAR G_TYPE_MAKE_FUNDAMENTAL (3)
constant G_TYPE_CHAR is export = 3 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_UCHAR G_TYPE_MAKE_FUNDAMENTAL (4)
constant G_TYPE_UCHAR is export = 4 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_BOOLEAN G_TYPE_MAKE_FUNDAMENTAL (5)
constant G_TYPE_BOOLEAN is export = 5 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_INT G_TYPE_MAKE_FUNDAMENTAL (6)
constant G_TYPE_INT is export = 6 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_UINT G_TYPE_MAKE_FUNDAMENTAL (7)
constant G_TYPE_UINT is export = 7 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_LONG G_TYPE_MAKE_FUNDAMENTAL (8)
constant G_TYPE_LONG is export = 8 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_ULONG G_TYPE_MAKE_FUNDAMENTAL (9)
constant G_TYPE_ULONG is export = 9 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_INT64 G_TYPE_MAKE_FUNDAMENTAL (10)
constant G_TYPE_INT64 is export = 10 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_UINT64 G_TYPE_MAKE_FUNDAMENTAL (11)
constant G_TYPE_UINT64 is export = 11 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_ENUM G_TYPE_MAKE_FUNDAMENTAL (12)
constant G_TYPE_ENUM is export = 12 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_FLAGS G_TYPE_MAKE_FUNDAMENTAL (13)
constant G_TYPE_FLAGS is export = 13 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_FLOAT G_TYPE_MAKE_FUNDAMENTAL (14)
constant G_TYPE_FLOAT is export = 14 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_DOUBLE G_TYPE_MAKE_FUNDAMENTAL (15)
constant G_TYPE_DOUBLE is export = 15 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_STRING G_TYPE_MAKE_FUNDAMENTAL (16)
constant G_TYPE_STRING is export = 16 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_POINTER G_TYPE_MAKE_FUNDAMENTAL (17)
constant G_TYPE_POINTER is export = 17 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_BOXED G_TYPE_MAKE_FUNDAMENTAL (18)
constant G_TYPE_BOXED is export = 18 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_PARAM G_TYPE_MAKE_FUNDAMENTAL (19)
constant G_TYPE_PARAM is export = 19 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define G_TYPE_OBJECT G_TYPE_MAKE_FUNDAMENTAL (20)
constant G_TYPE_OBJECT is export = 20 +< G_TYPE_FUNDAMENTAL_SHIFT;

#define	G_TYPE_VARIANT G_TYPE_MAKE_FUNDAMENTAL (21)
constant G_TYPE_VARIANT is export = 21 +< G_TYPE_FUNDAMENTAL_SHIFT;

#-------------------------------------------------------------------------------
sub g_type_name ( int32 $type --> Str )
  is native(&gobject-lib)
  { * }

sub g_type_from_name ( Str --> int32 )
  is native(&gobject-lib)
  { * }

sub g_type_parent ( int32 $type --> int32 )
  is native(&gobject-lib)
  { * }

sub g_type_depth ( int32 $type --> uint32 )
  is native(&gobject-lib)
  { * }

sub g_type_check_value ( N-GValue $gvalue --> int32 )
  is native(&gobject-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
#submethod BUILD ( ) { }

#-------------------------------------------------------------------------------
method FALLBACK ( $native-sub is copy, |c ) {

  CATCH { test-catch-exception( $_, $native-sub); }

  $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-');
  die X::GTK::V3.new(:message(
      "Native sub name '$native-sub' made too short. Keep atleast one '-' or '_'."
    )
  ) unless $native-sub.index('_');

  my Callable $s;
  try { $s = &::($native-sub); }
  try { $s = &::("g_type_$native-sub") unless ?$s; }

  $s(|c)
}
