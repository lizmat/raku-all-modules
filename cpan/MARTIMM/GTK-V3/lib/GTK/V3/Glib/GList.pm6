use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/glib/glist.h
# https://developer.gnome.org/glib/stable/glib-Doubly-Linked-Lists.html
unit class GTK::V3::Glib::GList:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
class N-GList is repr('CPointer') is export { }

#-------------------------------------------------------------------------------
sub g_list_first ( N-GList $list )
  returns N-GList
  is native(&gtk-lib)
  { * }

sub g_list_last ( N-GList $list )
  returns N-GList
  is native(&gtk-lib)
  { * }

sub g_list_length ( N-GList $list )
  returns int32
  is native(&gtk-lib)
  { * }

sub g_list_nth ( N-GList $list, int32 $n)
  returns N-GList
  is native(&gtk-lib)
  { * }

sub g_list_nth_data ( N-GList $list, int32 $n)
  returns N-GObject
  is native(&gtk-lib)
  { * }

#TODO free $!g-list too
sub g_list_free ( N-GList $list )
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
has N-GList $!glist;

#-------------------------------------------------------------------------------
submethod BUILD ( N-GList:D :$!glist ) { }

#-------------------------------------------------------------------------------
method CALL-ME ( N-GList $glist? --> N-GList ) {

  $!glist = $glist if ?$glist;
  $!glist
}

#-------------------------------------------------------------------------------
method FALLBACK ( $native-sub is copy, |c ) {

  CATCH { test-catch-exception( $_, $native-sub); }

  $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-');

  my Callable $s;
  try { $s = &::($native-sub); }
  try { $s = &::("g_list_$native-sub"); }

  test-call( $s, $!glist, |c)
}

#`{{
#-------------------------------------------------------------------------------
method g_list_previous( N-GList $list --> N-GList ) {
  $!g-list.prev
}

#-------------------------------------------------------------------------------
method g_list_next( N-GList $list --> N-GList ) {
  $!g-list.next
}
}}
