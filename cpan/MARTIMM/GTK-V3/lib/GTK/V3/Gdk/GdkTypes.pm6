use v6;
use NativeCall;

#use GTK::V3::X;
use GTK::V3::N::NativeLib;
#use GTK::V3::Glib::GObject;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gdk/gdktypes.h
unit class GTK::V3::Gdk::GdkTypes:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
enum GdkWindowTypeHint <
  GDK_WINDOW_TYPE_HINT_NORMAL
  GDK_WINDOW_TYPE_HINT_DIALOG
  GDK_WINDOW_TYPE_HINT_MENU
  GDK_WINDOW_TYPE_HINT_TOOLBAR
  GDK_WINDOW_TYPE_HINT_SPLASHSCREEN
  GDK_WINDOW_TYPE_HINT_UTILITY
  GDK_WINDOW_TYPE_HINT_DOCK
  GDK_WINDOW_TYPE_HINT_DESKTOP
  GDK_WINDOW_TYPE_HINT_DROPDOWN_MENU
  GDK_WINDOW_TYPE_HINT_POPUP_MENU
  GDK_WINDOW_TYPE_HINT_TOOLTIP
  GDK_WINDOW_TYPE_HINT_NOTIFICATION
  GDK_WINDOW_TYPE_HINT_COMBO
  GDK_WINDOW_TYPE_HINT_DND
>;
