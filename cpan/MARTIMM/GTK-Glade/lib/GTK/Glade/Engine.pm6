use v6;
use NativeCall;

use GTK::V3::Gtk::GtkMain;
use GTK::V3::Gtk::GtkTextIter;
use GTK::V3::Gtk::GtkTextBuffer;
use GTK::V3::Gtk::GtkTextView;

#-------------------------------------------------------------------------------
unit class GTK::Glade::Engine:auth<github:MARTIMM>;

has GTK::V3::Gtk::GtkMain $!main;
has GTK::V3::Gtk::GtkTextBuffer $!text-buffer;
has GTK::V3::Gtk::GtkTextView $!text-view;

#-------------------------------------------------------------------------------
method glade-get-text ( Str:D $id --> Str ) {

  $!text-view .= new(:build-id($id));
  $!text-buffer .= new(:widget($!text-view.get-buffer));

  my GTK::V3::Gtk::GtkTextIter $start .= new;
  $!text-buffer.get-start-iter($start);
  my GTK::V3::Gtk::GtkTextIter $end .= new;
  $!text-buffer.get-end-iter($end);

  $!text-buffer.get-text( $start, $end)
}

#-------------------------------------------------------------------------------
method glade-set-text ( Str:D $id, Str:D $text ) {

  $!text-view .= new(:build-id($id));
  $!text-buffer .= new(:widget($!text-view.get-buffer));
  $!text-buffer.set-text( $text, $text.chars);
}

#-------------------------------------------------------------------------------
method glade-add-text ( Str:D $id, Str:D $text is copy ) {

  $!text-view .= new(:build-id($id));
  $!text-buffer .= new(:widget($!text-view.get-buffer));

  my GTK::V3::Gtk::GtkTextIter $start .= new;
  $!text-buffer.get-start-iter($start);
  my GTK::V3::Gtk::GtkTextIter $end .= new;
  $!text-buffer.get-end-iter($end);

  $text = $!text-buffer.get-text( $start, $end, 1) ~ $text;
  $!text-buffer.set-text( $text, $text.chars);
}

#-------------------------------------------------------------------------------
# Get the text and clear text field. Returns the original text
method glade-clear-text ( Str:D $id --> Str ) {

  $!text-view .= new(:build-id($id));
  $!text-buffer .= new(:widget($!text-view.get-buffer));

  my GTK::V3::Gtk::GtkTextIter $start .= new;
  $!text-buffer.get-start-iter($start);
  my GTK::V3::Gtk::GtkTextIter $end .= new;
  $!text-buffer.get-end-iter($end);

  my Str $text = $!text-buffer.get-text( $start, $end, 1);
  $!text-buffer.set-text( "", 0);

  $text
}

#-------------------------------------------------------------------------------
method glade-main-level ( ) {
  $!main.gtk-main-level;
}

#-------------------------------------------------------------------------------
method glade-main-quit ( ) {
  $!main.gtk-main-quit;
}
