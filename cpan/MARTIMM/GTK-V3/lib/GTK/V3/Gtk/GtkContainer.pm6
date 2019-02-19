use v6;
use NativeCall;

use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Glib::GList;
use GTK::V3::Gtk::GtkWidget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkcontainer.h
# https://developer.gnome.org/gtk3/stable/GtkContainer.html
unit class GTK::V3::Gtk::GtkContainer:auth<github:MARTIMM>
  is GTK::V3::Gtk::GtkWidget;

#-------------------------------------------------------------------------------
sub gtk_container_add ( N-GObject $container, N-GObject $widget )
  is native(&gtk-lib)
  { * }

sub gtk_container_get_border_width ( N-GObject $container )
  returns int32
  is native(&gtk-lib)
  { * }

sub gtk_container_get_children ( N-GObject $container )
  returns N-GList
  is native(&gtk-lib)
  { * }

sub gtk_container_set_border_width (
  N-GObject $container, int32 $border_width
) is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkContainer';

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
  try { $s = &::("gtk_container_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s
}
