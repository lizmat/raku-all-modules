use v6;
use Test;
use ABC::Utils;

is default-length-from-meter("4/4"),  "1/8",  "4/4 defaults to eighth note";
is default-length-from-meter("2/2"),  "1/8",  "2/2 defaults to eighth note";
is default-length-from-meter("3/4"),  "1/8",  "3/4 defaults to eighth note";
is default-length-from-meter("6/8"),  "1/8",  "6/8 defaults to eighth note";
is default-length-from-meter("2/4"),  "1/16", "2/4 defaults to sixteenth note";
is default-length-from-meter("C"),    "1/8",  "Common time defaults to eighth note";
is default-length-from-meter("C|"),   "1/8",  "Cut time defaults to eighth note";
is default-length-from-meter(""),     "1/8",  "No meter defaults to eighth note";
is default-length-from-meter("none"), "1/8",  "No meter defaults to eighth note";

for flat 'A'..'G' X 2..8 -> $note, $octave-number {
    my ($pitch, $symbol) = from-note-and-number($note, $octave-number);
    my ($computed-note, $computed-number) = to-note-and-number($pitch, $symbol);
    is $computed-note, $note, "Note is correct after round trip through note-and-symbol";
    is $computed-number, $octave-number, "Octave number is correct after round trip through note-and-symbol";
}

my %key;
is pitch-to-ordinal(%key, "", "C", ""), 0, "Middle C is correct";
is pitch-to-ordinal(%key, "^", "B", ","), 0, "B-sharp below middle C is correct";
is pitch-to-ordinal(%key, "__", "D", ""), 0, "D-double-flat above middle C is correct";
is pitch-to-ordinal(%key, "", "c", ""), 12, "Third space C is correct";
is pitch-to-ordinal(%key, "^", "B", ""), 12, "Middle line B-sharp is correct";
is pitch-to-ordinal(%key, "__", "d", ""), 12, "Fourth line D-double-flat is correct";
is ordinal-to-pitch(%key, "C", 0), ("", "C", ""), "Middle C translates back okay";
is ordinal-to-pitch(%key, "B", 0), ("^", "B", ","), "B-sharp below middle C translates back okay";
is ordinal-to-pitch(%key, "D", 0), ("__", "D", ""), "D-double-flat above middle C translates back okay";
is ordinal-to-pitch(%key, "C", 12), ("", "c", ""), "Third space C translates back okay";
is ordinal-to-pitch(%key, "B", 12), ("^", "B", ""), "Middle line B-sharp translates back okay";
is ordinal-to-pitch(%key, "D", 12), ("__", "d", ""), "Fourth line D-double-flat translates back okay";

done-testing;