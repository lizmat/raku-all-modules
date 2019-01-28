use v6;

use NativeCall;
use GTK::Glade::NativeGtk :ALL;
use GTK::Glade::Native::Gtk;
use GTK::Glade::Native::Gtk::Widget;
use GTK::Glade::Native::Gtk::Builder;

#-------------------------------------------------------------------------------
unit class GTK::Glade::Engine:auth<github:MARTIMM>;

# Must be set before by GTK::Glade.
has $.builder is rw;

#-------------------------------------------------------------------------------
method glade-start-iter ( $buffer ) {
  my $iter_mem = CArray[int32].new;
  $iter_mem[31] = 0; # Just need a blob of memory.
  gtk_text_buffer_get_start_iter( $buffer, $iter_mem);
  $iter_mem
}

#-------------------------------------------------------------------------------
method glade-end-iter ( $buffer ) {
  my $iter_mem = CArray[int32].new;
  $iter_mem[16] = 0;
  gtk_text_buffer_get_end_iter( $buffer, $iter_mem);
  $iter_mem
}

#-------------------------------------------------------------------------------
method glade-get-widget ( Str:D $id --> Any ) {
  gtk_builder_get_object( $!builder, $id)
}

#-------------------------------------------------------------------------------
method glade-get-text ( Str:D $id --> Str ) {

  my GtkWidget $widget = gtk_builder_get_object( $!builder, $id);
  my $buffer = gtk_text_view_get_buffer($widget);

  gtk_text_buffer_get_text(
    $buffer, self.glade-start-iter($buffer), self.glade-end-iter($buffer), 1
  )
}

#-------------------------------------------------------------------------------
method glade-set-text ( Str:D $id, Str:D $text ) {

  my GtkWidget $widget = gtk_builder_get_object( $!builder, $id);
  my $buffer = gtk_text_view_get_buffer($widget);
  gtk_text_buffer_set_text( $buffer, $text, -1);
}

#-------------------------------------------------------------------------------
method glade-add-text ( Str:D $id, Str:D $text is copy ) {

  my GtkWidget $widget = gtk_builder_get_object( $!builder, $id);
  my $buffer = gtk_text_view_get_buffer($widget);

  $text = gtk_text_buffer_get_text(
    $buffer, self.glade-start-iter($buffer), self.glade-end-iter($buffer), 1
  ) ~ $text;

  gtk_text_buffer_set_text( $buffer, $text, -1);
}

#-------------------------------------------------------------------------------
# Get the text and clear text field. Returns the original text
method glade-clear-text ( Str:D $id --> Str ) {

  my GtkWidget $widget = gtk_builder_get_object( $!builder, $id);
  my $buffer = gtk_text_view_get_buffer($widget);
  my Str $text = gtk_text_buffer_get_text(
    $buffer, self.glade-start-iter($buffer), self.glade-end-iter($buffer), 1
  );

  gtk_text_buffer_set_text( $buffer, "", -1);

  $text
}
