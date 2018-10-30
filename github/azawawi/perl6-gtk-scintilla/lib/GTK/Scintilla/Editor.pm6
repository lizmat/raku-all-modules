use v6;

use NativeCall;
use GTK::Scintilla;
use GTK::Scintilla::Raw;
use GTK::Simple::Widget;

unit class GTK::Scintilla::Editor does GTK::Simple::Widget;

=begin pod

=head1 Name

GTK::Scintilla::Editor - GTK Scintilla Editor Widget

=head1 Synopsis

    use v6;

    use GTK::Simple::App;
    use GTK::Scintilla;
    use GTK::Scintilla::Editor;

    my $app = GTK::Simple::App.new( title => "Hello GTK + Scintilla!" );

    my $editor = GTK::Scintilla::Editor.new;
    $editor.size-request(500, 300);
    $app.set-content($editor);

    $editor.style-clear-all;
    $editor.lexer(SCLEX_PERL);
    $editor.style-foreground( SCE_PL_COMMENTLINE, 0x008000 );
    $editor.style-foreground( SCE_PL_POD        , 0x008000 );
    $editor.style-foreground( SCE_PL_NUMBER     , 0x808000 );
    $editor.style-foreground( SCE_PL_WORD       , 0x800000 );
    $editor.style-foreground( SCE_PL_STRING     , 0x800080 );
    $editor.style-foreground( SCE_PL_OPERATOR   , 1 );
    $editor.text(q{
    # A Perl comment
    use Modern::Perl;

    say "Hello world";
    });

    $editor.show;
    $app.run;

=head1 Description

GTK::Scintilla is a L<GTK::Simple> widget that provides advanced source code
editing features. Some examples of text editors that are based on
L<Scintilla|http://scintilla.org> by Neil Hodgson et al:

=item L<Geany (cross-platform)|https://www.geany.org>
=item L<Notepad++ (Windows)|https://notepad-plus-plus.org>
=item L<Padre (Perl IDE)|http://padre.perlide.org>
=item L<SciTE (cross-platform, developed by the same author)|http://www.scintilla.org/SciTE.html>

=head1 Methods
=end pod

submethod BUILD(Int $id = 0) {
    $!gtk_widget = gtk_scintilla_new;
    gtk_scintilla_set_id($!gtk_widget, $id);
    return;
}

method style-clear-all {
    gtk_scintilla_send_message($!gtk_widget, 2050, 0, 0);
    return;
}

method style-foreground(Int $style, Int $color) {
    gtk_scintilla_send_message($!gtk_widget, 2051, $style, $color);
}

multi method style-bold(Int $style, Bool $bold) {
    gtk_scintilla_send_message($!gtk_widget, 2053, $style, $bold ?? 1 !! 0);
    return;
}

multi method style-bold(Int $style) returns Bool {
    return gtk_scintilla_send_message($!gtk_widget, 2483, $style, 0) == 1;
}

multi method lexer(Int $lexer) {
    gtk_scintilla_send_message($!gtk_widget, 4001, $lexer, 0);
    return;
}

#------------------------------------------------------------------------------#

=begin pod

=head2 Selection and information

Scintilla maintains a selection that stretches between two points, the anchor
and the current position. If the anchor and the current position are the same,
there is no selected text. Positions in the document range from 0 (before the
first character), to the document size (after the last character). If you use
messages, there is nothing to stop you setting a position that is in the middle
of a CRLF pair, or in the middle of a 2 byte character. However, keyboard
commands will not move the caret into such positions.
=end pod

=begin pod
=head3 modified

Returns whether the document is different from when it was last saved or not.
=end pod
method modified returns Bool {
    return gtk_scintilla_send_message($!gtk_widget, 2159, 0, 0) == 1;
}

=begin pod
=head3 selection-start(Int $anchor)

Sets the position that starts the selection. This becomes the anchor.
=end pod
multi method selection-start(Int $anchor) {
    gtk_scintilla_send_message($!gtk_widget, 2142, $anchor, 0);
    return;
}

=begin pod
=head3 selection-start returns Int

Returns the position at the start of the selection.
=end pod
multi method selection-start returns Int {
    return gtk_scintilla_send_message($!gtk_widget, 2143, 0, 0);
}

=begin pod
=head3 selection-end(Int $caret)

Sets the position that ends the selection. This becomes the caret.
=end pod
multi method selection-end(Int $caret) {
    gtk_scintilla_send_message($!gtk_widget, 2144, $caret, 0);
    return;
}

=begin pod
=head3 selection-end returns Int

Returns the position at the end of the selection.
=end pod
multi method selection-end returns Int {
    return gtk_scintilla_send_message($!gtk_widget, 2145, 0, 0);
}

=begin pod
=head3 empty-selection(Int $caret)

Sets the caret to a position, while removing any existing selection. The caret
is not scrolled into view.
=end pod
multi method empty-selection(Int $caret) {
    gtk_scintilla_send_message($!gtk_widget, 2556, $caret, 0);
    return;
}

=begin pod
=head3 select-all

Select all the text in the document.
=end pod
method select-all {
    gtk_scintilla_send_message($!gtk_widget, 2013, 0, 0);
    return;
}

#------------------------------------------------------------------------------#

=begin pod

=head2 Cut, copy and paste

The following methods provide clipboard-related operations.
=end pod

=begin pod
=head3 cut

Cut the selection to the clipboard.
=end pod
method cut {
    gtk_scintilla_send_message($!gtk_widget, 2177, 0, 0);
    return;
}

=begin pod
=head3 copy

Copy the selection to the clipboard.
=end pod
method copy {
    gtk_scintilla_send_message($!gtk_widget, 2178, 0, 0);
    return;
}

=begin pod
=head3 paste

Paste the contents of the clipboard into the document replacing the selection.
=end pod
method paste {
    gtk_scintilla_send_message($!gtk_widget, 2179, 0, 0);
    return;
}

=begin pod
=head3 clear

Clear the selection.
=end pod
method clear {
    gtk_scintilla_send_message($!gtk_widget, 2180, 0, 0);
    return;
}

=begin pod
=head3 can-paste

Returns whether a paste will succeed or not.
=end pod
method can-paste {
    return gtk_scintilla_send_message($!gtk_widget, 2173, 0, 0) == 1;
}

=begin pod
=head3 copy-range(Int $start, Int $end)

Copy a range of text to the clipboard. Positions are clipped into the document.
=end pod
method copy-range(Int $start, Int $end) {
    gtk_scintilla_send_message($!gtk_widget, 2419, $start, $end);
    return;
}

=begin pod
=head3 copy-text(Str $text)

Copy argument text to the clipboard.
=end pod
method copy-text(Str $text) {
    gtk_scintilla_send_message_str($!gtk_widget, 2420, $text.chars, $text);
    return;
}

=begin pod
=head3 copy-allow-line

Copy the selection, if selection empty copy the line with the caret.
=end pod
method copy-allow-line {
    gtk_scintilla_send_message($!gtk_widget, 2519, 0, 0);
    return;
}

=begin pod
=head3 paste-convert-endings(Bool $convert)

Enable or disable convert-on-paste for line endings
=end pod
multi method paste-convert-endings(Bool $convert) {
    gtk_scintilla_send_message($!gtk_widget, 2467, $convert ?? 1 !! 0, 0);
    return;
}

=begin pod
=head3 paste-convert-endings returns Bool

Returns whether convert-on-paste for line endings is enabled or disabled.
=end pod
multi method paste-convert-endings returns Bool {
    return gtk_scintilla_send_message($!gtk_widget, 2468, 0, 0) == 1;
}

#------------------------------------------------------------------------------#

=begin pod

=head2 Text retrieval and modification


Each byte in a Scintilla document is associated with a byte of styling
information. The combination of a character byte and a style byte is called a
cell. Style bytes are interpreted an index into an array of styles.

In this document, 'character' normally refers to a byte even when multi-byte
characters are used. Lengths measure the numbers of bytes, not the amount of
characters in those bytes.

Positions within the Scintilla document refer to a character or the gap before
that character. The first character in a document is 0, the second 1 and so on.
If a document contains nLen characters, the last character is numbered nLen-1.
The caret exists between character positions and can be located from before the
first character (0) to after the last character (nLen).

There are places where the caret can not go where two character bytes make up
one character. This occurs when a DBCS character from a language like Japanese
is included in the document or when line ends are marked with the CP/M standard
of a carriage return followed by a line feed. The INVALID_POSITION constant (-1)
represents an invalid position within the document.

All lines of text in Scintilla are the same height, and this height is
calculated from the largest font in any current style. This restriction is for
performance; if lines differed in height then calculations involving positioning
of text would require the text to be styled first.
=end pod

=begin pod
=head3 insert-text(Int $pos, Str $text)

Insert string at a position.
=end pod
method insert-text(Int $pos, Str $text) {
    gtk_scintilla_send_message_str($!gtk_widget, 2003, $pos, $text);
    return;
}

#
# SCI_APPENDTEXT(int length, const char *text)
#
method append-text(Str $text) {
    gtk_scintilla_send_message_str($!gtk_widget, 2282, $text.chars, $text);
    return;
}

=begin pod
=head3 add-text(Str $text)

Add text to the document at current position.
=end pod
method add-text(Str $text) {
    gtk_scintilla_send_message_str($!gtk_widget, 2001, $text.chars, $text);
    return;
}

=begin pod
=head3 delete-range(Int $start, Int $length)

Delete a range of text in the document.
=end pod
method delete-range(Int $start, Int $length) {
    gtk_scintilla_send_message($!gtk_widget, 2645, $start, $length);
    return;
}

#
# SCI_GETCHARAT(int pos) → int
#
multi method char-at(Int $position) returns Str {
    my $ch = gtk_scintilla_send_message($!gtk_widget, 2007, $position, 0);
    #TODO fire X:Scintilla::InvalidPosition exception?
    return $ch != 0 ?? chr($ch) !! "";
}

=begin pod
=head3 length

Returns the number of bytes in the document.
=end pod
method length returns Int {
    return gtk_scintilla_send_message($!gtk_widget, 2006, 0, 0);
}

#
# SCI_GETTEXTLENGTH => int
#
multi method text-length returns Int {
    return gtk_scintilla_send_message($!gtk_widget, 2183, 0, 0);
}

=begin pod
=head3 current-pos

Returns the position of the caret.
=end pod
multi method current-pos returns Int {
    return gtk_scintilla_send_message($!gtk_widget, 2008, 0, 0);
}

=begin pod
=head3 current-pos(Int $caret)

Sets the position of the caret.
=end pod
multi method current-pos(Int $caret) {
    gtk_scintilla_send_message($!gtk_widget, 2141, $caret, 0);
    return;
}

=begin pod
=head3 text(Str $text)

Replace the contents of the document with the argument text.
=end pod
multi method text(Str $text) {
    gtk_scintilla_send_message_str($!gtk_widget, 2181, 0, $text);
    return;
}

=begin pod
=head3 text

Returns all the text in the document.
=end pod
multi method text returns Str {
    my $buffer-length = self.text-length + 1;
    my $buffer = CArray[uint8].new;
    $buffer[$buffer-length - 1] = 0;
    my $len = gtk_scintilla_send_message_carray($!gtk_widget, 2182,
        $buffer-length, $buffer);
    my $text = '';
    for 0..$buffer-length - 2 -> $i {
        $text ~= chr($buffer[$i]);
    }
    return $text;
}

=begin pod
=head3 save-point

Remember the current position in the undo history as the position at which the
document was saved.
=end pod
method save-point {
    gtk_scintilla_send_message($!gtk_widget, 2014, 0, 0);
    return;
}

=begin pod
=head3 line(Int $line) returns Str

Returns the line string of the zero-based line number.
=end pod
multi method line(Int $line) returns Str {
    my $buffer-length = self.line-length($line) + 1;
    my $buffer = CArray[uint8].new;
    $buffer[$buffer-length - 1] = 0;
    my $len = gtk_scintilla_send_message_carray($!gtk_widget, 2153,
        $line, $buffer);
    my $text = '';
    for 0..$buffer-length - 2 -> $i {
        $text ~= chr($buffer[$i]);
    }
    return $text;
}

=begin pod
=head3 read-only(Bool $enabled)

Enable/Disable read-only mode.
=end pod
multi method read-only(Bool $enabled) {
    gtk_scintilla_send_message($!gtk_widget, 2171, $enabled ?? 1 !! 0, 0);
    return;
}

=begin pod
=head3 read-only returns Bool

Returns whether the document is in read-only mode or not.
=end pod
multi method read-only returns Bool {
    return gtk_scintilla_send_message($!gtk_widget, 2140, 0, 0) == 1;
}

=begin pod
=head3 line-length(Int $line) returns Int

Returns how many characters are on a line including end of line characters. The
line number is zero-based.
=end pod
method line-length(Int $line) returns Int {
    return gtk_scintilla_send_message($!gtk_widget, 2350, $line, 0);
}

=begin pod
=head3 clear-all

Delete all text in the document unless the document is read-only.
=end pod
method clear-all {
    gtk_scintilla_send_message($!gtk_widget, 2004, 0, 0);
    return;
}

=begin pod
=head3 line-count returns Int

Returns the number of lines in the document. There is always at least one.
=end pod
multi method line-count returns Int {
    return gtk_scintilla_send_message($!gtk_widget, 2154, 0, 0);
}

##----------------------------------------------------------------------------##

=begin pod

=head2 Long lines

You can choose to mark lines that exceed a given length by drawing a vertical
line or by coloring the background of characters that exceed the set length.
=end pod

=begin pod
=head3 edge-mode(EdgeMode $mode)

Sets the edge highlight mode. The edge may be displayed by a line
(C<Line>/C<MultiLine>) or by highlighting text that goes beyond it
(C<Background>) or not displayed at all (C<None>).
=end pod
multi method edge-mode(EdgeMode $mode) {
    gtk_scintilla_send_message($!gtk_widget, 2363, $mode, 0);
    return;
}

=begin pod
=head3 edge-mode returns EdgeMode

Returns the edge highlight mode.
=end pod
multi method edge-mode returns EdgeMode {
    return EdgeMode(gtk_scintilla_send_message($!gtk_widget, 2362, 0, 0));
}

=begin pod
=head3 edge-column(Int $column)

Set the column number of the edge. If text goes past the edge then it is
highlighted.
=end pod
multi method edge-column(Int $column) {
    gtk_scintilla_send_message($!gtk_widget, 2361, $column, 0);
    return;
}

=begin pod
=head3 edge-column returns Int

Returns the column number which text should be kept within.
=end pod
multi method edge-column returns Int {
    return gtk_scintilla_send_message($!gtk_widget, 2360, 0, 0);
}

=begin pod
=head3 edge-color(Int $color)

Sets the color used in edge indication.
=end pod
multi method edge-color(Int $color) {
    gtk_scintilla_send_message($!gtk_widget, 2365, $color, 0);
    return;
}

=begin pod
=head3 edge-color returns Int

Returns the color used in edge indication.
=end pod
multi method edge-color returns Int {
    return gtk_scintilla_send_message($!gtk_widget, 2364, 0, 0);
}

#------------------------------------------------------------------------------#

=begin pod

=head2 Zooming

Scintilla incorporates a "zoom factor" that lets you make all the text in the
document larger or smaller in steps of one point. The displayed point size never
goes below 2, whatever zoom factor you set. You can set zoom factors in the
range -10 to +20 points.
=end pod

=begin pod
=head3 zoom-in

Magnify the displayed text by increasing the sizes by 1 point.
=end pod
method zoom-in {
    gtk_scintilla_send_message($!gtk_widget, 2333, 0, 0);
    return;
}

=begin pod
=head3 zoom-out

Make the displayed text smaller by decreasing the sizes by 1 point.
=end pod
method zoom-out {
    gtk_scintilla_send_message($!gtk_widget, 2334, 0, 0);
    return;
}

=begin pod
=head3 zoom(Int $zoom-in-points)

Set the zoom level. This number of points is added to the size of all fonts. It
may be positive to magnify or negative to reduce.
=end pod
multi method zoom(Int $zoom-in-points) {
    gtk_scintilla_send_message($!gtk_widget, 2373, $zoom-in-points, 0);
    return;
}

=begin pod
=head3 zoom returns Int

Returns the zoom level.
=end pod
multi method zoom returns Int {
    return gtk_scintilla_send_message($!gtk_widget, 2374, 0, 0);
}

#------------------------------------------------------------------------------#

=begin pod

=head2 Undo and Redo

Scintilla has multiple level undo and redo. It will continue to collect undoable
actions until memory runs out. Scintilla saves actions that change the document.
Scintilla does not save caret and selection movements, view scrolling and the
like. Sequences of typing or deleting are compressed into single transactions to
make it easier to undo and redo at a sensible level of detail. Sequences of
actions can be combined into transactions that are undone as a unit. These
sequences occur between C<begin-undo-action> and C<end-undo-action> messages.
These transactions can be nested and only the top-level sequences are undone as
units.
=end pod

=begin pod
=head3 undo

Undo one action in the undo history.
=end pod
method undo {
    gtk_scintilla_send_message($!gtk_widget, 2176, 0, 0);
    return;
}

=begin pod
=head3 can-undo

Returns whether there any undoable actions in the undo history or not.
=end pod
method can-undo returns Bool {
    return gtk_scintilla_send_message($!gtk_widget, 2174, 0, 0) == 1;
}


=begin pod
=head3 empty-undo-buffer

Delete the undo history.
=end pod
method empty-undo-buffer {
    gtk_scintilla_send_message($!gtk_widget, 2175, 0, 0);
    return;
}

=begin pod
=head3 redo

Redo the next action on the undo history.
=end pod
method redo {
    gtk_scintilla_send_message($!gtk_widget, 2011, 0, 0);
    return;
}

=begin pod
=head3 can-redo

Returns whether they are any redoable actions in the undo history or not.
=end pod
method can-redo returns Bool {
    return gtk_scintilla_send_message($!gtk_widget, 2016, 0, 0) == 1;
}

=begin pod
=head3 undo-collection(Bool $collect-undo)

Enable/disable the collection of the undo history.
=end pod
multi method undo-collection(Bool $collect-undo) {
    gtk_scintilla_send_message($!gtk_widget, 2012, $collect-undo ?? 1 !! 0, 0);
    return;
}

=begin pod
=head3 undo-collection returns Bool

Returns whether the undo history is being collected or not.
=end pod
multi method undo-collection returns Bool {
    return gtk_scintilla_send_message($!gtk_widget, 2019, 0, 0) == 1;
}

=begin pod
=head3 begin-undo-action

Start a sequence of actions that is undone and redone as one transaction. This
can be nested.
=end pod
method begin-undo-action {
    gtk_scintilla_send_message($!gtk_widget, 2078, 0, 0);
    return;
}

=begin pod
=head3 end-undo-action

End a sequence of actions that is undone and redone as one transaction.
=end pod
method end-undo-action {
    gtk_scintilla_send_message($!gtk_widget, 2079, 0, 0);
    return;
}

=begin pod
=head3 add-undo-action

Add a container action to the undo stack.
=end pod
method add-undo-action(Int $token, Int $flags) {
    gtk_scintilla_send_message($!gtk_widget, 2560, $token, $flags);
    return;
}

#------------------------------------------------------------------------------#

=begin pod

=head2 Cursor

The following methods provide cursor-related API. C<CursorType> is an
enumeration and can be one of the following values:

=item Normal
=item Arrow
=item Wait
=item ReverseArrow
=end pod

=begin pod
=head3 cursor(CursorType $type)

Sets the cursor type.
=end pod
multi method cursor(CursorType $type) {
    gtk_scintilla_send_message($!gtk_widget, 2386, Int($type), 0);
    return;
}

=begin pod
=head3 cursor returns CursorType

Returns the cursor type. Initially it is C<Normal>.
=end pod
multi method cursor returns CursorType {
    return CursorType(gtk_scintilla_send_message($!gtk_widget, 2387, 0, 0));
}
