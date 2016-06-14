use v6;

use GTK::Simple::Widget;
use GTK::Scintilla;
use GTK::Scintilla::Raw;

unit class GTK::Scintilla::Editor does GTK::Simple::Widget;

submethod BUILD(Int $id = 0) {
    $!gtk_widget = gtk_scintilla_new;
    gtk_scintilla_set_id($!gtk_widget, $id);
}

method style-clear-all {
    gtk_scintilla_send_message($!gtk_widget, SCI_STYLECLEARALL, 0, 0);
}

method style-set-foreground(Int $style, Int $color) {
    gtk_scintilla_send_message($!gtk_widget, SCI_STYLESETFORE, $style, $color);
}

method set-lexer(Int $lexer) {
    gtk_scintilla_send_message($!gtk_widget, SCI_SETLEXER, $lexer, 0);
}

method insert-text(Int $pos, Str $text) {
    gtk_scintilla_send_message_str($!gtk_widget, SCI_INSERTTEXT, $pos, $text);
}

method get-length() {
    gtk_scintilla_send_message($!gtk_widget, SCI_GETTEXTLENGTH, 0, 0);
}

##  Long line API
#
# SCI_SETEDGEMODE(int edgeMode)
# SCI_GETEDGEMODE
#
method set-edge-mode(Int $edge-mode) {
    gtk_scintilla_send_message($!gtk_widget, SCI_SETEDGEMODE, $edge-mode, 0);
}

method get-edge-mode returns Int {
    gtk_scintilla_send_message($!gtk_widget, SCI_GETEDGEMODE, 0, 0);
}

#
# SCI_SETEDGECOLUMN(int column)
# SCI_GETEDGECOLUMN
#
method set-edge-column(Int $column) {
    gtk_scintilla_send_message($!gtk_widget, SCI_SETEDGECOLUMN, $column, 0);
}

method get-edge-column returns Int {
    gtk_scintilla_send_message($!gtk_widget, SCI_GETEDGECOLUMN, 0, 0);
}

#
# SCI_SETEDGECOLOUR(int colour)
# SCI_GETEDGECOLOUR
#
method set-edge-color(Int $color) {
    gtk_scintilla_send_message($!gtk_widget, SCI_SETEDGECOLOUR, $color, 0);
}

method get-edge-color returns Int {
    gtk_scintilla_send_message($!gtk_widget, SCI_GETEDGECOLOUR, 0, 0);
}

#
# Zoom API
#
# SCI_ZOOMIN
# SCI_ZOOMOUT
# SCI_SETZOOM(int zoomInPoints)
# SCI_GETZOOM
#
method zoom-in {
    gtk_scintilla_send_message($!gtk_widget, SCI_ZOOMIN, 0, 0);
}

method zoom-out {
    gtk_scintilla_send_message($!gtk_widget, SCI_ZOOMOUT, 0, 0);
}

method set-zoom(Int $zoom-in-points) {
    gtk_scintilla_send_message($!gtk_widget, SCI_SETZOOM, $zoom-in-points, 0);
}

method get-zoom returns Int {
    gtk_scintilla_send_message($!gtk_widget, SCI_GETZOOM, 0, 0);
}

=begin pod

=head1 Name

GTK::Scintilla::Editor - GTK Scintilla Editor Widget

=head1 Synopsis

TODO Add Synopsis ection documentation

=head1 Description

TODO Add Description section documentation

=head1 Methods

=head2 Long lines

Please see L<here|http://www.scintilla.org/ScintillaDoc.html#LongLines>.

=head3 set-edge-mode

=head3 get-edge-mode

=head3 set-edge-column

=head3 get-edge-column

=head3 set-edge-color

=head3 get-edge-color


=head2 Zooming

Please see L<here|http://www.scintilla.org/ScintillaDoc.html#Zooming>.

=head3 zoom-in

=head3 zoom-out

=head3 set-zoom

=head3 get-zoom

=end pod
