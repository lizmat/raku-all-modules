use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gdk::GdkScreen;
use GTK::V3::Gtk::GtkMain;
#use GTK::V3::Glib::GError;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkbuilder.h
# https://developer.gnome.org/gtk3/stable/GtkBuilder.html
unit class GTK::V3::Gtk::GtkBuilder:auth<github:MARTIMM>
  is GTK::V3::Glib::GObject;

#-------------------------------------------------------------------------------
# GtkBuilder *gtk_builder_new (void);
sub gtk_builder_new ()
  returns N-GObject       # GtkBuilder
  is native(&gtk-lib)
  { * }

# GtkBuilder *gtk_builder_new_from_string (const gchar *string, gssize length);
sub gtk_builder_new_from_file ( Str $glade-ui )
  returns N-GObject
  is native(&gtk-lib)
  { * }

# GtkBuilder *gtk_builder_new_from_string (const gchar *string, gssize length);
sub gtk_builder_new_from_string ( Str $glade-ui, uint32 $length)
  returns N-GObject
  is native(&gtk-lib)
  { * }

sub gtk_builder_add_from_file (
  N-GObject $builder, Str $glade-ui, OpaquePointer
#  N-GObject $builder, Str $glade-ui, N-GError $error is rw
) returns int32         # 0 or 1, 1 = ok, 0 look into GError
  is native(&gtk-lib)
    { * }

sub gtk_builder_add_from_string (
  N-GObject $builder, Str $glade-ui, uint32 $size, OpaquePointer
#  N-GObject $builder, Str $glade-ui, uint32 $size, N-GError $error is rw
) returns int32         # 0 or 1, 1 = ok, 0 look into GError
  is native(&gtk-lib)
  { * }

sub gtk_builder_get_object (
  N-GObject $builder, Str $object-id
) returns N-GObject   # is GObject
  is native(&gtk-lib)
  { * }

sub gtk_builder_get_type_from_name ( N-GObject $builder, Str $type_name )
  returns int32         # is GType
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkBuilder';

  if ? %options<filename> {
    self.native-gobject(gtk_builder_new_from_file(%options<filename>));
  }

  elsif ? %options<string> {
    self.native-gobject(
      gtk_builder_new_from_string( %options<string>, %options<string>.chars)
    );
  }

  elsif ? %options<empty> {
    self.native-gobject(gtk_builder_new());
  }

  elsif ? %options<widget> || %options<build-id> {
    # provided in GObject
  }

  elsif %options.keys.elems {
    die X::GTK::V3.new(
      :message('Unsupported options for ' ~ self.^name ~
               ': ' ~ %options.keys.join(', ')
              )
    );
  }

  self.set-builder(self);
}

#-------------------------------------------------------------------------------
method fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::($native-sub); }
  try { $s = &::("gtk_builder_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
multi method add-gui ( Str:D :$filename! ) {

  my $g := self;
  my Int $e-code = gtk_builder_add_from_file( $g(), $filename, Any);
  die X::GTK::V3.new(:message("Error adding file '$filename' to the Gui"))
      if $e-code == 0;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
multi method add-gui ( Str:D :$string! ) {

  my $g := self;
  my Int $e-code = gtk_builder_add_from_string(
    $g(), $string, $string.chars, Any
  );

  die X::GTK::V3.new(:message("Error adding xml text to the Gui"))
      if $e-code == 0;
}
