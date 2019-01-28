use v6;
use NativeCall;

use GTK::Glade::NativeLib;
#use GTK::Glade::NativeGtk :ALL;
use GTK::Glade::Native::Gtk;
use GTK::Glade::Native::Gdk;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk on Fedora-28
unit module GTK::Glade::Native::Gtk::Builder:auth<github:MARTIMM>;


#--[ builder_ ]-----------------------------------------------------------------
class GtkBuilder is repr('CPointer') { }
class GtkCssSection is repr('CPointer') is export { }
class GtkCssProvider is repr('CPointer') is export { }

# GtkBuilder *gtk_builder_new (void);
sub gtk_builder_new ()
    returns GtkBuilder
    is native(&gtk-lib)
    is export
    { * }

# GtkBuilder *gtk_builder_new_from_string (const gchar *string, gssize length);
sub gtk_builder_new_from_file ( Str $glade-ui )
    returns GtkBuilder
    is native(&gtk-lib)
    is export
    { * }

# GtkBuilder *gtk_builder_new_from_string (const gchar *string, gssize length);
sub gtk_builder_new_from_string ( Str $glade-ui, uint32 $length)
    returns GtkBuilder
    is native(&gtk-lib)
    is export
    { * }

# guint gtk_builder_add_from_file(
#      GtkBuilder builder, const gchar *filename, GError **error);
sub gtk_builder_add_from_file (
    GtkBuilder $builder, Str $glade-ui, GError $error is rw
    ) returns int32
      is native(&gtk-lib)
      is export
      { * }

# guint gtk_builder_add_from_string ( GtkBuilder *builder,
#       const gchar *buffer, gsize length, GError **error);
sub gtk_builder_add_from_string (
    GtkBuilder $builder, Str $glade-ui, uint32 $size, GError $error is rw
    ) returns int32
      is native(&gtk-lib)
      is export
      { * }

# GObject *gtk_builder_get_object (
#      GtkBuilder *builder, const gchar *name);
sub gtk_builder_get_object (
    GtkBuilder $builder, Str $object-id
    ) returns GtkWidget
      is native(&gtk-lib)
      is export
      { * }

#--[ css style ]----------------------------------------------------------------
# /usr/include/glib-2.0/gtk/gtkstyleprovider.h
# https://developer.gnome.org/gtk3/stable/GtkStyleProvider.html#GTK-STYLE-PROVIDER-PRIORITY-FALLBACK:CAPS

enum GtkStyleProviderPriority is export (
    GTK_STYLE_PROVIDER_PRIORITY_FALLBACK => 1,
    GTK_STYLE_PROVIDER_PRIORITY_THEME => 200,
    GTK_STYLE_PROVIDER_PRIORITY_SETTINGS => 400,
    GTK_STYLE_PROVIDER_PRIORITY_APPLICATION => 600,
    GTK_STYLE_PROVIDER_PRIORITY_USER => 800,
);


sub gtk_css_provider_new ( )
    returns GtkCssProvider
    is native(&gtk-lib)
    is export
    { * }

sub gtk_css_provider_get_named ( Str $name, Str $variant )
    returns GtkCssProvider
    is native(&gtk-lib)
    is export
    { * }

sub gtk_css_provider_load_from_path (
    GtkCssProvider $css_provider, Str $css-file, GError $error is rw
    ) is native(&gtk-lib)
      is export
      { * }

sub gtk_style_context_add_provider_for_screen (
    GdkScreen $screen, int32 $provider, int32 $priority
    ) is native(&gtk-lib)
      is export
      { * }
