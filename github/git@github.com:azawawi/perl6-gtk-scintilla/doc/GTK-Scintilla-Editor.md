Name
====

GTK::Scintilla::Editor - GTK Scintilla Editor Widget

Synopsis
========

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

Description
===========

GTK::Scintilla is a [GTK::Simple](GTK::Simple) widget that provides advanced source code editing features. Some examples of text editors that are based on [Scintilla](http://scintilla.org) by Neil Hodgson et al:

  * [Geany (cross-platform)](https://www.geany.org)

  * [Notepad++ (Windows)](https://notepad-plus-plus.org)

  * [Padre (Perl IDE)](http://padre.perlide.org)

  * [SciTE (cross-platform, developed by the same author)](http://www.scintilla.org/SciTE.html)

Methods
=======

Selection and information
-------------------------

Scintilla maintains a selection that stretches between two points, the anchor and the current position. If the anchor and the current position are the same, there is no selected text. Positions in the document range from 0 (before the first character), to the document size (after the last character). If you use messages, there is nothing to stop you setting a position that is in the middle of a CRLF pair, or in the middle of a 2 byte character. However, keyboard commands will not move the caret into such positions.

### modified

Returns whether the document is different from when it was last saved or not.

### selection-start(Int $anchor)

Sets the position that starts the selection. This becomes the anchor.

### selection-start returns Int

Returns the position at the start of the selection.

### selection-end(Int $caret)

Sets the position that ends the selection. This becomes the caret.

### selection-end returns Int

Returns the position at the end of the selection.

### empty-selection(Int $caret)

Sets the caret to a position, while removing any existing selection. The caret is not scrolled into view.

### select-all

Select all the text in the document.

Cut, copy and paste
-------------------

The following methods provide clipboard-related operations.

### cut

Cut the selection to the clipboard.

### copy

Copy the selection to the clipboard.

### paste

Paste the contents of the clipboard into the document replacing the selection.

### clear

Clear the selection.

### can-paste

Returns whether a paste will succeed or not.

### copy-range(Int $start, Int $end)

Copy a range of text to the clipboard. Positions are clipped into the document.

### copy-text(Str $text)

Copy argument text to the clipboard.

### copy-allow-line

Copy the selection, if selection empty copy the line with the caret.

### paste-convert-endings(Bool $convert)

Enable or disable convert-on-paste for line endings

### paste-convert-endings returns Bool

Returns whether convert-on-paste for line endings is enabled or disabled.

Text retrieval and modification
-------------------------------

Each byte in a Scintilla document is associated with a byte of styling information. The combination of a character byte and a style byte is called a cell. Style bytes are interpreted an index into an array of styles.

In this document, 'character' normally refers to a byte even when multi-byte characters are used. Lengths measure the numbers of bytes, not the amount of characters in those bytes.

Positions within the Scintilla document refer to a character or the gap before that character. The first character in a document is 0, the second 1 and so on. If a document contains nLen characters, the last character is numbered nLen-1. The caret exists between character positions and can be located from before the first character (0) to after the last character (nLen).

There are places where the caret can not go where two character bytes make up one character. This occurs when a DBCS character from a language like Japanese is included in the document or when line ends are marked with the CP/M standard of a carriage return followed by a line feed. The INVALID_POSITION constant (-1) represents an invalid position within the document.

All lines of text in Scintilla are the same height, and this height is calculated from the largest font in any current style. This restriction is for performance; if lines differed in height then calculations involving positioning of text would require the text to be styled first.

### insert-text(Int $pos, Str $text)

Insert string at a position.

### add-text(Str $text)

Add text to the document at current position.

### delete-range(Int $start, Int $length)

Delete a range of text in the document.

### length

Returns the number of bytes in the document.

### current-pos

Returns the position of the caret.

### current-pos(Int $caret)

Sets the position of the caret.

### text(Str $text)

Replace the contents of the document with the argument text.

### text

Returns all the text in the document.

### save-point

Remember the current position in the undo history as the position at which the document was saved.

### line(Int $line) returns Str

Returns the line string of the zero-based line number.

### read-only(Bool $enabled)

Enable/Disable read-only mode.

### read-only returns Bool

Returns whether the document is in read-only mode or not.

### line-length(Int $line) returns Int

Returns how many characters are on a line including end of line characters. The line number is zero-based.

### clear-all

Delete all text in the document unless the document is read-only.

### line-count returns Int

Returns the number of lines in the document. There is always at least one.

Long lines
----------

You can choose to mark lines that exceed a given length by drawing a vertical line or by coloring the background of characters that exceed the set length.

### edge-mode(EdgeMode $mode)

Sets the edge highlight mode. The edge may be displayed by a line (`Line`/`MultiLine`) or by highlighting text that goes beyond it (`Background`) or not displayed at all (`None`).

### edge-mode returns EdgeMode

Returns the edge highlight mode.

### edge-column(Int $column)

Set the column number of the edge. If text goes past the edge then it is highlighted.

### edge-column returns Int

Returns the column number which text should be kept within.

### edge-color(Int $color)

Sets the color used in edge indication.

### edge-color returns Int

Returns the color used in edge indication.

Zooming
-------

Scintilla incorporates a "zoom factor" that lets you make all the text in the document larger or smaller in steps of one point. The displayed point size never goes below 2, whatever zoom factor you set. You can set zoom factors in the range -10 to +20 points.

### zoom-in

Magnify the displayed text by increasing the sizes by 1 point.

### zoom-out

Make the displayed text smaller by decreasing the sizes by 1 point.

### zoom(Int $zoom-in-points)

Set the zoom level. This number of points is added to the size of all fonts. It may be positive to magnify or negative to reduce.

### zoom returns Int

Returns the zoom level.

Undo and Redo
-------------

Scintilla has multiple level undo and redo. It will continue to collect undoable actions until memory runs out. Scintilla saves actions that change the document. Scintilla does not save caret and selection movements, view scrolling and the like. Sequences of typing or deleting are compressed into single transactions to make it easier to undo and redo at a sensible level of detail. Sequences of actions can be combined into transactions that are undone as a unit. These sequences occur between `begin-undo-action` and `end-undo-action` messages. These transactions can be nested and only the top-level sequences are undone as units.

### undo

Undo one action in the undo history.

### can-undo

Returns whether there any undoable actions in the undo history or not.

### empty-undo-buffer

Delete the undo history.

### redo

Redo the next action on the undo history.

### can-redo

Returns whether they are any redoable actions in the undo history or not.

### undo-collection(Bool $collect-undo)

Enable/disable the collection of the undo history.

### undo-collection returns Bool

Returns whether the undo history is being collected or not.

### begin-undo-action

Start a sequence of actions that is undone and redone as one transaction. This can be nested.

### end-undo-action

End a sequence of actions that is undone and redone as one transaction.

### add-undo-action

Add a container action to the undo stack.

Cursor
------

The following methods provide cursor-related API. `CursorType` is an enumeration and can be one of the following values:

  * Normal

  * Arrow

  * Wait

  * ReverseArrow

### cursor(CursorType $type)

Sets the cursor type.

### cursor returns CursorType

Returns the cursor type. Initially it is `Normal`.
