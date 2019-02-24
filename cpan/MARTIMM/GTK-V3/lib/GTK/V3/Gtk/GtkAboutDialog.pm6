use v6;
# ==============================================================================
=begin pod

=TITLE class GTK::V3::Gtk::GtkAboutDialog

=SUBTITLE

  unit class GTK::V3::Gtk::GtkAboutDialog;
  also is GTK::V3::Gtk::GtkDialog;

=head1 Synopsis

  use GTK::V3::Gtk::GtkAboutDialog $about .= new(:empty);
  $about.set-program-name('My-First-GTK-Program');

  # show the dialog
  $about.gtk-dialog-run;

  # when dialog buttons are pressed hide it again
  $about.gtk-widget-hide

=head1 Methods

All methods can be written with dashes or shortened by cutting the C<gtk_about_dialog_> part. This cannot be done when e.g. C<new> is left after the shortening. That would become an entirely other method. See the synopsis above for an example. Below, this is shown with brackets in the headers.
=end pod
# ==============================================================================

use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkDialog;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkaboutdialog.h
# https://developer.gnome.org/gtk3/stable/GtkAboutDialog.html
unit class GTK::V3::Gtk::GtkAboutDialog:auth<github:MARTIMM>
  is GTK::V3::Gtk::GtkDialog;

#-------------------------------------------------------------------------------
enum GtkLicense is export <
  GTK_LICENSE_UNKNOWN
  GTK_LICENSE_CUSTOM

  GTK_LICENSE_GPL_2_0
  GTK_LICENSE_GPL_3_0

  GTK_LICENSE_LGPL_2_1
  GTK_LICENSE_LGPL_3_0

  GTK_LICENSE_BSD
  GTK_LICENSE_MIT_X11

  GTK_LICENSE_ARTISTIC

  GTK_LICENSE_GPL_2_0_ONLY
  GTK_LICENSE_GPL_3_0_ONLY
  GTK_LICENSE_LGPL_2_1_ONLY
  GTK_LICENSE_LGPL_3_0_ONLY

  GTK_LICENSE_AGPL_3_0
  GTK_LICENSE_AGPL_3_0_ONLY
>;

# ==============================================================================
=begin pod
=head2 gtk_about_dialog_new

  method gtk_about_dialog_new ( --> N-GObject )

Creates a new empty about dialog widget. It returns a native object which must be stored in another object. Better, shorter and easier is to use C<.new(:empty)>. See info below.
=end pod
sub gtk_about_dialog_new ( )
  returns N-GObject       # GtkAboutDialog
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] get_program_name

  method gtk_about_dialog_get_program_name ( --> Str )

Get the program name from the dialog.
=end pod
sub gtk_about_dialog_get_program_name ( N-GObject $dialog )
  returns Str
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] set_program_name

  method gtk_about_dialog_set_program_name ( Str $pname )

Set the program name in the about dialog.
=end pod
sub gtk_about_dialog_set_program_name ( N-GObject $dialog, Str $pname )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] get_version

  method gtk_about_dialog_get_version ( --> Str )

Get the version
=end pod
sub gtk_about_dialog_get_version ( N-GObject $dialog )
  returns Str
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] set_version

  method gtk_about_dialog_set_version ( Str $version )

Set version
=end pod
sub gtk_about_dialog_set_version ( N-GObject $dialog, Str $version )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] get_copyright

  method gtk_about_dialog_get_copyright

=end pod
sub gtk_about_dialog_get_copyright ( N-GObject $dialog )
  returns Str
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] set_copyright

  method gtk_about_dialog_set_copyright

=end pod
sub gtk_about_dialog_set_copyright ( N-GObject $dialog, Str $copyright )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] get_comments

  method gtk_about_dialog_get_comments

=end pod
sub gtk_about_dialog_get_comments ( N-GObject $dialog )
  returns Str
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] set_comments

  method gtk_about_dialog_set_comments

=end pod
sub gtk_about_dialog_set_comments ( N-GObject $dialog, Str $comments )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] get_license

  method gtk_about_dialog_get_license

=end pod
sub gtk_about_dialog_get_license ( N-GObject $dialog )
  returns Str
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] set_license

  method gtk_about_dialog_set_license

=end pod
sub gtk_about_dialog_set_license ( N-GObject $dialog, Str $license )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] get_wrap_license

  method gtk_about_dialog_get_wrap_license

=end pod
sub gtk_about_dialog_get_wrap_license ( N-GObject $dialog )
  returns Bool
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] set_wrap_license

  method gtk_about_dialog_set_wrap_license

=end pod
sub gtk_about_dialog_set_wrap_license ( N-GObject $dialog, Bool $wrap_license )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] get_license_type

  method gtk_about_dialog_get_license_type

=end pod
sub gtk_about_dialog_get_license_type ( N-GObject $dialog )
  returns int32 # GtkLicense
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] set_license_type

  method gtk_about_dialog_set_license_type

=end pod
sub gtk_about_dialog_set_license_type ( N-GObject $dialog, int32 $license_type )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] get_website

  method gtk_about_dialog_get_website

=end pod
sub gtk_about_dialog_get_website ( N-GObject $dialog )
  returns Str
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] set_website

  method gtk_about_dialog_set_website

=end pod
sub gtk_about_dialog_set_website ( N-GObject $dialog, Str $website )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] get_website_label

  method gtk_about_dialog_get_website_label

=end pod
sub gtk_about_dialog_get_website_label ( N-GObject $dialog )
  returns Str
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] set_website_label

  method gtk_about_dialog_set_website_label

=end pod
sub gtk_about_dialog_set_website_label ( N-GObject $dialog, Str $website_label )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] get_authors

  method gtk_about_dialog_get_authors

=end pod
sub gtk_about_dialog_get_authors ( N-GObject $dialog )
  returns CArray[Str]
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] set_authors

  method gtk_about_dialog_set_authors

=end pod
sub gtk_about_dialog_set_authors ( N-GObject $dialog, CArray[Str] $authors )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] get_artists

  method gtk_about_dialog_get_artists

=end pod
sub gtk_about_dialog_get_artists ( N-GObject $dialog )
  returns CArray[Str]
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] set_artists

  method gtk_about_dialog_set_artists

=end pod
sub gtk_about_dialog_set_artists ( N-GObject $dialog, CArray[Str] $artists )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] get_documenters

  method gtk_about_dialog_get_documenters

=end pod
sub gtk_about_dialog_get_documenters ( N-GObject $dialog )
  returns CArray[Str]
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] set_documenters

  method gtk_about_dialog_set_documenters

=end pod
sub gtk_about_dialog_set_documenters (
  N-GObject $dialog, CArray[Str] $documenters
) is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] get_translator_credits

  method gtk_about_dialog_get_translator_credits

=end pod
sub gtk_about_dialog_get_translator_credits ( N-GObject $dialog )
  returns Str
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] set_translator_credits

  method gtk_about_dialog_set_translator_credits

=end pod
sub gtk_about_dialog_set_translator_credits (
  N-GObject $dialog , Str $translator_credits
) is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] get_logo

  method gtk_about_dialog_get_logo

=end pod
sub gtk_about_dialog_get_logo ( N-GObject $dialog )
  returns OpaquePointer # GdkPixbuf
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] set_logo

  method gtk_about_dialog_set_logo ( OpaquePointer $logo-pixbuf )

Set the logo from a pixel buffer.
=end pod
sub gtk_about_dialog_set_logo ( N-GObject $dialog, OpaquePointer $logo-pixbuf )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] get_logo_icon_name

  method gtk_about_dialog_get_logo_icon_name

=end pod
sub gtk_about_dialog_get_logo_icon_name ( N-GObject $dialog )
  returns Str
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] set_logo_icon_name

  method gtk_about_dialog_set_logo_icon_name

=end pod
sub gtk_about_dialog_set_logo_icon_name ( N-GObject $dialo, Str $icon_name )
  is native(&gtk-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [gtk_about_dialog_] add_credit_section

  method gtk_about_dialog_add_credit_section

=end pod
sub gtk_about_dialog_add_credit_section (
  N-GObject $dialo, Str $section_name, CArray[Str] $people
) is native(&gtk-lib)
  { * }


# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
=begin pod
=head2 new

  multi submethod BUILD (:empty!)

Create an empty about dialog

  multi submethod BUILD (:widget!)

Create an about dialog using a native object from elsewhere. See also Gtk::V3::Glib::GObject.

  multi submethod BUILD (:build-id!)

Create an about dialog using a native object from a builder. See also Gtk::V3::Glib::GObject.

=end pod
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkAboutDialog';

  if ? %options<empty> {
    self.native-gobject(gtk_about_dialog_new());
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
}

#-------------------------------------------------------------------------------
method fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::($native-sub); }
  try { $s = &::("gtk_about_dialog_$native-sub"); } unless ?$s;

note "ad $native-sub: ", $s;
  $s = callsame unless ?$s;

  $s;
}
