use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/glib/gslist.h
# https://developer.gnome.org/glib/stable/glib-Singly-Linked-List.html
unit class GTK::V3::Glib::GSList:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
class N-GSList is repr('CPointer') is export { }

#-------------------------------------------------------------------------------
sub g_slist_length ( N-GSList $list --> uint32 )
  is native(&gtk-lib)
  { * }

sub g_slist_last ( N-GSList $list --> N-GSList )
  is native(&gtk-lib)
  { * }

sub g_slist_nth ( N-GSList $list, uint32 $n --> N-GSList )
  is native(&gtk-lib)
  { * }

sub g_slist_nth_data ( N-GSList $list, uint32 $n --> N-GObject )
  is native(&gtk-lib)
  { * }

#TODO free $!gslist too?
sub g_slist_free ( N-GSList $list )
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
has N-GSList $!gslist;

#-------------------------------------------------------------------------------
submethod BUILD ( N-GSList:D :$!gslist ) { }

#-------------------------------------------------------------------------------
method CALL-ME ( N-GSList $gslist? --> N-GSList ) {

  $!gslist = $gslist if ?$gslist;
  $!gslist
}

#-------------------------------------------------------------------------------
method FALLBACK ( $native-sub is copy, |c ) {

  CATCH { test-catch-exception( $_, $native-sub); }

  $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-');

  my Callable $s;
  try { $s = &::($native-sub); }
  try { $s = &::("g_slist_$native-sub"); }

  test-call( $s, $!gslist, |c)
}

#`{{
#-------------------------------------------------------------------------------
method g_list_previous( N-GSList $list --> N-GSList ) {
  $!g-list.prev
}

#-------------------------------------------------------------------------------
method g_list_next( N-GSList $list --> N-GSList ) {
  $!g-list.next
}
}}
