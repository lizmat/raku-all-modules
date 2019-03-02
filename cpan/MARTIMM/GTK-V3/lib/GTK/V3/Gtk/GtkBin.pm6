use v6;
# ==============================================================================
=begin pod

=TITLE class GTK::V3::Gtk::GtkBin

=SUBTITLE

  unit class GTK::V3::Gtk::GtkBin;
  also is GTK::V3::Gtk::GtkContainer;

=head1 Synopsis

The module GtkBin is not used directly but its methods can be used by its child modules. Below is an example using a C<GtkButton> which is a direct descendant of C<GtkBin>. Also, here it is also clear that a button is also a container which in principle can hold anything but by default a label. The method C<gtk-container-add()> comes from C<GtkContainer> and C<get-child()> comes from C<GtkBin>.

  my GTK::V3::Gtk::GtkLabel $label .= new(:label<pqr>);
  my GTK::V3::Gtk::GtkButton $button .= new(:empty);
  $button.gtk-container-add($label);

  $l($button2.get-child);
  is $l.get-text, 'pqr', 'text label from button 2';

Of course, it is easier to do the next

  my GTK::V3::Gtk::GtkButton $button .= new(:label<pqr>);

=end pod
# ==============================================================================

use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkContainer;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkbin.h
# https://developer.gnome.org/gtk3/stable/GtkBin.html
unit class GTK::V3::Gtk::GtkBin:auth<github:MARTIMM>;
also is GTK::V3::Gtk::GtkContainer;

#-------------------------------------------------------------------------------
=begin pod

=head1 Methods

All methods can be written with dashes or shortened by cutting the C<gtk_bin_> part. After shortening, at least one dash or underscore must be left. Below, this is shown with brackets in the headers.

=head2 [gtk_bin_] get_child

  method gtk_about_dialog_new ( --> N-GObject )

Gets the child of the GtkBin, or C<Any> if the bin contains no child widget.
=end pod
sub gtk_bin_get_child ( N-GObject $bin )
  returns N-GObject
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkBin';

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
  try { $s = &::("gtk_bin_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s;
}
