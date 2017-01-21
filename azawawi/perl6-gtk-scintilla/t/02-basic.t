use v6;
use Test;

use GTK::Simple::App;
use GTK::Scintilla;
use GTK::Scintilla::Editor;

# Test data
my @lines = [ "Line #0\n", "Line #1\n", "Line #2" ];

plan 50 + @lines.elems * 2;

# Test version method
my $version = GTK::Scintilla.version;
say $version;
ok( $version<major>  == 3,       "Major version match" );
ok( $version<minor>  == 7,       "Minor version match" );
ok( $version<patch>  == 2,       "Patch version match" );
ok( $version<string> eq "3.7.2", "Version string match" );

# Create GTK application
my $app = GTK::Simple::App.new(title => "Hello GTK + Scintilla!");

# Create editor widget
my $editor = GTK::Scintilla::Editor.new;
$editor.size-request(500, 300);
$app.set-content($editor);

# Test text, text and text-length equality
my $text = @lines.join("");
$editor.text($text);
ok( $editor.text        eq $text,       "get and set text works" );
ok( $editor.text-length eq $text.chars, "text-length works");

# Test append-text
{
    constant TEXT = "XYZ\n";
    $editor.text($text);
    $editor.append-text(TEXT);
    ok( $editor.text.ends-with(TEXT), ".append-text works" );
}

# Test add-text
{
    constant TEXT = "ABC\n";
    $editor.text($text);
    $editor.add-text(TEXT);
    $editor.add-text("\n");
    ok( $editor.text eq (TEXT ~ "\n" ~ $text), ".add-text works" );
}

# Test delete-range
$editor.text($text);
$editor.delete-range(1, 5);
my $text-after-delete = $text.substr(0, 1) ~ $text.substr(6);
ok( $editor.text eq $text-after-delete, ".delete-range works");

# Test char-at
$editor.text($text);
ok( $editor.char-at(0)  eq $text.comb[0], "char-at(0) works");
ok( $editor.char-at(5)  eq $text.comb[5], "char-at(5) works");
ok( $editor.char-at(-1) eq "",            "invalid position returns empty string");

# Test line-length and line return values
$editor.text($text);
my $num-lines = @lines.elems;
for 0..@lines.elems - 1 -> $i {
    my $line = @lines[$i];
    ok( $editor.line-length($i) == $line.chars, "line-length($i) works");
    ok( $editor.line($i)        eq $line,       "line($i) works");
}

# Test length
$editor.text("");
ok( $editor.length == 0, ".length works");
$editor.text($text);
ok( $editor.length >= $text.chars, ".length works");

# Test line-count
ok($editor.line-count == $num-lines, "line-count works");

# Test out-of-range indices for line-length and line
ok($editor.line-length(-1)         eq 0,  "line(-1) must return zero");
ok($editor.line(-1)                eq "", "line(-1) must return empty string");
ok($editor.line-length($num-lines) eq 0,  "line($num-lines) must return also zero");
ok($editor.line($num-lines)        eq "", "line($num-lines) must return also empty string");

# Test save-point and modified
{
    $editor.text($text);
    ok( $editor.modified,     ".modified is true after a replace text operation" );
    $editor.save-point;
    ok( not $editor.modified, ".modified is false after a save point" );
    $editor.text($text);
    ok( $editor.modified,     ".modified is true again after a replace text operation" );
}

# Test current-pos
{
    $editor.text($text);
    ok( $editor.current-pos == 0, "By default current caret position is zero");
    $editor.current-pos(5);
    ok( $editor.current-pos == 5, "current-pos setter/getter works");
}

$editor.clear-all;
ok($editor.text-length == 0,  "clear-all & text-length works");
ok($editor.text        eq "", "clear-all & text works");
ok($editor.line-count  == 1,  "clear-all & line-count works");

# Test set/get bold style
$editor.style-bold(0, True);
ok( $editor.style-bold(0), "set, get bold works");

# Before an undo
ok( $editor.can-undo,     "can-undo is True");
ok( not $editor.can-redo, "can-redo is False");

# After an undo
$editor.undo;
ok( $editor.can-undo,          "can-undo is False");
ok( $editor.can-redo,          "can-redo is True");
ok( $editor.text eq $text, "undo works" );

# After a redo
$editor.redo;
ok( $editor.text eq "", "redo works" );

# After an empty-undo-buffer
$editor.empty-undo-buffer;
ok( !$editor.can-undo, "empty-undo-buffer works");

# Test begin and undo action (aka transaction)
$editor.clear-all;
$editor.begin-undo-action;
$editor.text("ABC\n");
$editor.append-text("DEF\n");
$editor.end-undo-action;
$editor.undo;
ok( $editor.text eq "", "begin and end undo action work");

# Test selection
{
    constant SELECTION-START = 1;
    constant SELECTION-END   = 5;

    $editor.text($text);
    $editor.selection-start(SELECTION-START);
    $editor.selection-end(SELECTION-END);
    ok( $editor.selection-start == SELECTION-START &&
        $editor.selection-end   == SELECTION-END,
        "set/get selection start/end works");

    $editor.select-all;
    ok( $editor.selection-start == 0 &&
        $editor.selection-end   == $text.chars, "select-all works");

    $editor.empty-selection(SELECTION-END);
    ok( $editor.selection-start == SELECTION-END &&
        $editor.selection-end   == SELECTION-END, "empty-selection works");
}

# Test set/get read only
{
    ok( !$editor.read-only, "By default the document is not read-only");
    $editor.read-only(True);
    ok( $editor.read-only,  "set/get read-only works");
    $editor.read-only(False);
}

# Test cut, copy, clear and paste
{
    constant TEXT = "Hello world";

    $editor.clear-all;
    $editor.copy-text(TEXT);
    $editor.paste;
    ok( $editor.text, TEXT);

    ok( $editor.can-paste, "can-paste is True on a non-readonly document");
    $editor.read-only(True);
    ok( !$editor.can-paste, "can-paste is False on a readonly document");
    $editor.read-only(False);
}

# Test get/set cursor
{
    ok( $editor.cursor == Normal, "By default, cursor is normal" );
    $editor.cursor(Wait);
    ok( $editor.cursor == Wait, "set/get cursor works" );
    $editor.cursor(Normal);
}

# Test edge-mode
{
    ok( $editor.edge-mode == None, "By default edge mode is None" );
    $editor.edge-mode(Line);
    ok( $editor.edge-mode == Line, "edge mode getter, setter works" );
    $editor.edge-mode(None);
}

# Test edge-column
{
    constant EDGE_COLUMN = 78;
    ok( $editor.edge-column == 0,         "By default edge column is zero" );
    $editor.edge-column(EDGE_COLUMN);
    ok( $editor.edge-column == EDGE_COLUMN, "edge column getter, setter works" );
}
