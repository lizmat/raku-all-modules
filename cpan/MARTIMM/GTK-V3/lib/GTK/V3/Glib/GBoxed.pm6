use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/glib/gboxed.h
# https://developer.gnome.org/gobject/stable/gobject-Boxed-Types.html
unit class GTK::V3::Glib::GBoxed:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
# No subs implemented yet.
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
our $gboxed-debug = False; # Type Bool;

# No type specified. GBoxed is a wrapper for any structure
has $!g-boxed;

#-------------------------------------------------------------------------------
# submethod BUILD (*%options ) { }

#-------------------------------------------------------------------------------
#TODO destroy when overwritten?
method CALL-ME ( $g-boxed? --> Any ) {

  if ?$g-boxed {
    $!g-boxed = $g-boxed;
  }

  $!g-boxed
}

#-------------------------------------------------------------------------------
method FALLBACK ( $native-sub is copy, |c ) {

  CATCH { test-catch-exception( $_, $native-sub); }

  # convert all dashes to underscores if there are any. then check if
  # name is not too short.
  $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-');
  die X::GTK::V3.new(:message(
      "Native sub name '$native-sub' made too short. Keep atleast one '-' or '_'."
    )
  ) unless $native-sub.index('_');

  # check if there are underscores in the name. then the name is not too short.
  my Callable $s;

  # call the fallback functions of this classes children starting
  # at the bottom
  $s = self.fallback($native-sub);

  die X::GTK::V3.new(:message("Native sub '$native-sub' not found"))
      unless $s.defined;
#  unless $s.defined {
#    note "Native sub '$native-sub' not found";
#    return;
#  }

  # User convenience substitutions to get a native object instead of
  # a GtkSomeThing or GlibSomeThing object
  my Array $params = [];
  for c.list -> $p {
    if $p.^name ~~ m/^ 'GTK::V3::G' [ <[td]> k || lib ] '::'/ {
      $params.push($p());
    }

    else {
      $params.push($p);
    }
  }

  #note "\ntest-call of $native-sub: ", $s.gist, ', ', $!g-boxed, ', ', |c.gist
  #  if $gobject-debug;
  test-call( $s, $!g-boxed, |$params)
}

#-------------------------------------------------------------------------------
method fallback ( $native-sub is copy --> Callable ) {

#  my Callable $s;
#  try { $s = &::($native-sub); }
#  try { $s = &::("g_type_module_$native-sub"); } unless ?$s;

#  $s = callsame unless ?$s;

  my Callable $s = callsame;
  $s
}

#-------------------------------------------------------------------------------
method debug ( Bool :$on ) {
  $gboxed-debug = $on;
}

#-------------------------------------------------------------------------------
#TODO destroy when overwritten?
method native-gboxed ( $g-boxed? --> Any ) {
  if ?$g-boxed {
    $!g-boxed = $g-boxed;
  }

  $!g-boxed
}
