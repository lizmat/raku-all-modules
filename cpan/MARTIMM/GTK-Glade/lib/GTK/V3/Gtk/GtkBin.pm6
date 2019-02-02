use v6;
use NativeCall;

use GTK::Glade::Gui;
use GTK::V3::N::NativeLib;
use GTK::V3::Gtk::GtkWidget;
use GTK::V3::Gtk::GtkContainer;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkbin.h
# https://developer.gnome.org/gtk3/stable/GtkBin.html
unit class GTK::V3::Gtk::GtkBin:auth<github:MARTIMM>
  is GTK::V3::Gtk::GtkContainer
  does GTK::Glade::Gui;

#-------------------------------------------------------------------------------
sub gtk_bin_get_child ( N-GtkWidget $bin )
  returns N-GtkWidget
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
method fallback ( $native-sub is copy --> Callable ) {

  $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-');

  my Callable $s;
  try { $s = &::($native-sub); }
  try { $s = &::("gtk_bin_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  &$s
}
