use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gdk::GdkScreen;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkstylecontext.h
# https://developer.gnome.org/gtk3/stable/GtkStyleContext.html
unit class GTK::V3::Gtk::GtkStyleContext:auth<github:MARTIMM>
  is GTK::V3::Glib::GObject;

#-------------------------------------------------------------------------------
enum GtkStyleProviderPriority is export (
  GTK_STYLE_PROVIDER_PRIORITY_FALLBACK => 1,
  GTK_STYLE_PROVIDER_PRIORITY_THEME => 200,
  GTK_STYLE_PROVIDER_PRIORITY_SETTINGS => 400,
  GTK_STYLE_PROVIDER_PRIORITY_APPLICATION => 600,
  GTK_STYLE_PROVIDER_PRIORITY_USER => 800,
);

#-------------------------------------------------------------------------------
sub gtk_style_context_new ( --> N-GObject )
  is native(&gtk-lib)
  { * }

# special sub to cope with automatically inserted first argument caused by its
# type, thinking that would be a GtkStyleContext type but it is a GdkScreen
# type. Sometimes smart thinking goes the wrong way.
sub gtk_style_context_add_provider_for_screen( N-GObject, |c ) {
  hidden_gtk_style_context_add_provider_for_screen(|c);
}
sub hidden_gtk_style_context_add_provider_for_screen (
  N-GObject $screen, int32 $provider, int32 $priority
) is native(&gtk-lib)
  is symbol('gtk_style_context_add_provider_for_screen')
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkCssProvider';

  if ? %options<empty> {
    self.native-gobject(gtk_style_context_new());
  }

  elsif ? %options<widget> || ? %options<build-id> {
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
  try { $s = &::("gtk_style_context_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s
}
