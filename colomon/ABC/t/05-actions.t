use v6;
use Test;
use ABC::Header;
use ABC::Tune;
use ABC::Grammar;
use ABC::Actions;
use ABC::Note;
use ABC::Stem;
use ABC::Rest;
use ABC::Tuplet;
use ABC::BrokenRhythm;
use ABC::Chord;

{
    my $match = ABC::Grammar.parse('F#', :rule<chord>, :actions(ABC::Actions.new));
    ok $match, 'chord recognized';
    isa_ok $match.ast, ABC::Chord, '$match.ast is an ABC::Chord';
    is $match.ast.main-note, "F", "Pitch F";
    is $match.ast.main-accidental, "#", "...sharp";
}

{
    my $match = ABC::Grammar.parse('Bbmin/G#', :rule<chord>, :actions(ABC::Actions.new));
    ok $match, 'chord recognized';
    isa_ok $match.ast, ABC::Chord, '$match.ast is an ABC::Chord';
    is $match.ast.main-note, "B", "Pitch B";
    is $match.ast.main-accidental, "b", "...flat";
    is $match.ast.main-type, "min", "...min";
    is $match.ast.bass-note, "G", "over G";
    is $match.ast.bass-accidental, "#", "...#";
}

{
    my $match = ABC::Grammar.parse('"F#"', :rule<chord_or_text>, :actions(ABC::Actions.new));
    ok $match, 'chord_or_text recognized';
    isa_ok $match.ast[0], ABC::Chord, '$match.ast[0] is an ABC::Chord';
    is $match.ast[0].main-note, "F", "Pitch F";
    is $match.ast[0].main-accidental, "#", "...sharp";
}

{
    my $match = ABC::Grammar.parse('{gf}', :rule<grace_notes>, :actions(ABC::Actions.new));
    ok $match, 'grace_notes recognized';
    isa_ok $match.ast, ABC::GraceNotes, '$match.ast is an ABC::GraceNotes';
    nok $match.ast.acciaccatura, "It's not an acciaccatura";
    is $match.ast.notes[0].pitch, "g", "Pitch g found";
    is $match.ast.notes[1].pitch, "f", "Pitch g found";
}

{
    my $match = ABC::Grammar.parse('"F#"', :rule<element>, :actions(ABC::Actions.new));
    ok $match, 'element recognized';
    isa_ok $match.ast, Pair, '$match.ast is a Pair';
    is $match.ast.key, "chord_or_text", '$match.ast.key is "chord_or_text"';
    is $match.ast.value[0].main-note, "F", "Pitch F";
    is $match.ast.value[0].main-accidental, "#", "...sharp";
}

{
    my $match = ABC::Grammar.parse('"^Bb whistle"', :rule<element>, :actions(ABC::Actions.new));
    ok $match, 'element recognized';
    isa_ok $match.ast, Pair, '$match.ast is a Pair';
    is $match.ast.key, "chord_or_text", '$match.ast.key is "chord_or_text"';
    isa_ok $match.ast.value[0], Str, "And it's text";
    is $match.ast.value[0], "^Bb whistle", '$match.ast.value[0] is ^Bb whistle';
}

{
    my $match = ABC::Grammar.parse("e3", :rule<mnote>, :actions(ABC::Actions.new));
    ok $match, 'element recognized';
    isa_ok $match.ast, ABC::Note, '$match.ast is an ABC::Note';
    is $match.ast.pitch, "e", "Pitch e";
    is $match.ast.ticks, 3, "Duration 3 ticks";
}

{
    my $match = ABC::Grammar.parse("e", :rule<mnote>, :actions(ABC::Actions.new));
    ok $match, 'element recognized';
    isa_ok $match.ast, ABC::Note, '$match.ast is an ABC::Note';
    is $match.ast.pitch, "e", "Pitch e";
    is $match.ast.ticks, 1, "Duration 1 ticks";
}

{
    my $match = ABC::Grammar.parse("^e,/", :rule<mnote>, :actions(ABC::Actions.new));
    ok $match, 'element recognized';
    isa_ok $match.ast, ABC::Note, '$match.ast is an ABC::Note';
    is $match.ast.pitch, "^e,", "Pitch ^e,";
    is $match.ast.ticks, 1/2, "Duration 1/2 ticks";
}

{
    my $match = ABC::Grammar.parse("[a2bc]3", :rule<stem>, :actions(ABC::Actions.new));
    ok $match, 'element recognized';
    isa_ok $match.ast, ABC::Stem, '$match.ast is an ABC::Stem';
    is $match.ast.notes[0], "a2", "Pitch 1 a";
    is $match.ast.notes[1], "b", "Pitch 2 b";
    is $match.ast.notes[2], "c", "Pitch 3 c";
    is $match.ast.ticks, 6, "Duration 6 ticks";
    nok $match.ast.is-tie, "Not tied";
}

{
    my $match = ABC::Grammar.parse("[a2bc]/-", :rule<stem>, :actions(ABC::Actions.new));
    ok $match, 'element recognized';
    isa_ok $match.ast, ABC::Stem, '$match.ast is an ABC::Stem';
    is $match.ast.notes[0], "a2", "Pitch 1 a";
    is $match.ast.notes[1], "b", "Pitch 2 b";
    is $match.ast.notes[2], "c", "Pitch 3 c";
    is $match.ast.ticks, 1, "Duration 1 tick";
    ok $match.ast.is-tie, "Tied";
}

{
    my $match = ABC::Grammar.parse("z/", :rule<rest>, :actions(ABC::Actions.new));
    ok $match, 'rest recognized';
    isa_ok $match.ast, ABC::Rest, '$match.ast is an ABC::Rest';
    is $match.ast.type, "z", "Rest is z";
    is $match.ast.ticks, 1/2, "Duration 1/2 ticks";
}

{
    my $match = ABC::Grammar.parse("F3/2", :rule<mnote>, :actions(ABC::Actions.new));
    ok $match, 'element recognized';
    isa_ok $match.ast, ABC::Note, '$match.ast is an ABC::Note';
    is $match.ast.pitch, "F", "Pitch F";
    is $match.ast.ticks, 3/2, "Duration 3/2 ticks";
}

{
    my $match = ABC::Grammar.parse("F2/3", :rule<mnote>, :actions(ABC::Actions.new));
    ok $match, 'element recognized';
    isa_ok $match.ast, ABC::Note, '$match.ast is an ABC::Note';
    is $match.ast.pitch, "F", "Pitch F";
    is $match.ast.ticks, 2/3, "Duration 2/3 ticks";
}

{
    my $match = ABC::Grammar.parse("(3abc", :rule<tuplet>, :actions(ABC::Actions.new));
    ok $match, 'tuplet recognized';
    isa_ok $match.ast, ABC::Tuplet, '$match.ast is an ABC::Tuplet';
    is $match.ast.tuple, "3", "It's a triplet";
    is $match.ast.ticks, 2, "Duration 2 ticks";
    is +$match.ast.notes, 3, "Three internal note";
    ok $match.ast.notes[0] ~~ ABC::Stem | ABC::Note, "First internal note is of the correct type";
    is $match.ast.notes, "a b c", "Notes are correct";
}

{
    my $match = ABC::Grammar.parse("a>~b", :rule<broken_rhythm>, :actions(ABC::Actions.new));
    ok $match, 'broken rhythm recognized';
    isa_ok $match.ast, ABC::BrokenRhythm, '$match.ast is an ABC::BrokenRhythm';
    is $match.ast.ticks, 2, "total duration is two ticks";
    isa_ok $match.ast.effective-stem1, ABC::Note, "effective-stem1 is a note";
    is $match.ast.effective-stem1.pitch, "a", "first pitch is a";
    is $match.ast.effective-stem1.ticks, 1.5, "first duration is 1 + 1/2";
    isa_ok $match.ast.effective-stem2, ABC::Note, "effective-stem2 is a note";
    is $match.ast.effective-stem2.pitch, "b", "first pitch is a";
    is $match.ast.effective-stem2.ticks, .5, "second duration is 1/2";
}

{
    my $match = ABC::Grammar.parse("a<<<b", :rule<broken_rhythm>, :actions(ABC::Actions.new));
    ok $match, 'broken rhythm recognized';
    isa_ok $match.ast, ABC::BrokenRhythm, '$match.ast is an ABC::BrokenRhythm';
    is $match.ast.ticks, 2, "total duration is two ticks";
    isa_ok $match.ast.effective-stem1, ABC::Note, "effective-stem1 is a note";
    is $match.ast.effective-stem1.pitch, "a", "first pitch is a";
    is $match.ast.effective-stem1.ticks, 1/8, "first duration is 1/8";
    isa_ok $match.ast.effective-stem2, ABC::Note, "effective-stem2 is a note";
    is $match.ast.effective-stem2.pitch, "b", "first pitch is a";
    is $match.ast.effective-stem2.ticks, 15/8, "second duration is 1 + 7/8";
}

{
    my $match = ABC::Grammar.parse("[K:F]", :rule<element>, :actions(ABC::Actions.new));
    ok $match, 'inline field recognized';
    # isa_ok $match.ast, ABC::BrokenRhythm, '$match.ast is an ABC::BrokenRhythm';
    is $match<inline_field><alpha>, "K", "field type is K";
    is $match<inline_field><value>, "F", "field value is K";
}

{
    my $match = ABC::Grammar.parse("+fff+", :rule<long_gracing>, :actions(ABC::Actions.new));
    ok $match, 'long gracing recognized';
    isa_ok $match.ast, Str, '$match.ast is a Str';
    is $match.ast, "fff", "gracing is fff";
}

{
    my $match = ABC::Grammar.parse("+fff+", :rule<gracing>, :actions(ABC::Actions.new));
    ok $match, 'long gracing recognized';
    isa_ok $match.ast, Str, '$match.ast is a Str';
    is $match.ast, "fff", "gracing is fff";
}

{
    my $match = ABC::Grammar.parse("~", :rule<gracing>, :actions(ABC::Actions.new));
    ok $match, 'gracing recognized';
    isa_ok $match.ast, Str, '$match.ast is a Str';
    is $match.ast, "~", "gracing is ~";
}

{
    my $match = ABC::Grammar.parse("+fff+", :rule<element>, :actions(ABC::Actions.new));
    ok $match, 'long gracing recognized';
    is $match.ast.key, "gracing", '$match.ast.key is gracing';
    isa_ok $match.ast.value, Str, '$match.ast.value is a Str';
    is $match.ast.value, "fff", "gracing is fff";
}

{
    my $music = q«X:64
T:Cuckold Come Out o' the Amrey
S:Northumbrian Minstrelsy
M:4/4
L:1/8
K:D
»;
    my $match = ABC::Grammar.parse($music, :rule<header>, :actions(ABC::Actions.new));
    ok $match, 'tune recognized';
    isa_ok $match.ast, ABC::Header, '$match.ast is an ABC::Header';
    is $match.ast.get("T").elems, 1, "One T field found";
    is $match.ast.get("T")[0].value, "Cuckold Come Out o' the Amrey", "And it's correct";
    ok $match.ast.is-valid, "ABC::Header is valid";
}

{
    my $match = ABC::Grammar.parse("e3", :rule<element>, :actions(ABC::Actions.new));
    ok $match, 'element recognized';
    isa_ok $match.ast, Pair, '$match.ast is a Pair';
    is $match.ast.key, "stem", "Stem found";
    isa_ok $match.ast.value, ABC::Note, "Value is note";
}

{
    my $match = ABC::Grammar.parse("G2g gdc|", :rule<bar>, :actions(ABC::Actions.new));
    ok $match, 'element recognized';
    is $match.ast.elems, 7, '$match.ast has seven elements';
    is $match.ast[3].key, "stem", "Fourth is stem";
    is $match.ast[*-1].key, "barline", "Last is barline";
}

{
    my $match = ABC::Grammar.parse("G2g gdc", :rule<bar>, :actions(ABC::Actions.new));
    ok $match, 'element recognized';
    is $match.ast.elems, 6, '$match.ast has six elements';
    is $match.ast[3].key, "stem", "Fourth is stem";
    is $match.ast[*-1].key, "stem", "Last is stem";
}

{
    my $music = q«BAB G2G|G2g gdc|1BAB G2G|2=F2f fcA|
BAB G2G|G2g gdB|c2a B2g|A2=f fcA:|
»;

    my $match = ABC::Grammar.parse($music, :rule<music>, :actions(ABC::Actions.new));
    ok $match, 'element recognized';
#     say $match.ast.perl;
    is $match.ast.elems, 59, '$match.ast has 59 elements';
    # say $match.ast.elems;
    # say $match.ast[28].WHAT;
    # say $match.ast[28].perl;
    is $match.ast[22].key, "nth_repeat", "21st is nth_repeat";
    isa_ok $match.ast[22].value, Set, "21st value is a Set";
    ok $match.ast[22].value ~~ (set 2), "21st is '2'";
    is $match.ast[30].key, "endline", "29th is endline";
    is $match.ast[*-1].key, "endline", "Last is endline";
}

{
    my $music = q«BAB G2G|G2g gdc|BAB G2G|=F2f fcA|
BAB G2G|G2g gdB|c2a B2g|A2=f fcA:|
»;

    my $match = ABC::Grammar.parse($music, :rule<music>, :actions(ABC::Actions.new));
    ok $match, 'element recognized';
#     say $match.ast.perl;
    is $match.ast.elems, 57, '$match.ast has 57 elements';
    # say $match.ast.elems;
    # say $match.ast[28].WHAT;
    # say $match.ast[28].perl;
    is $match.ast[28].key, "endline", "29th is endline";
    is $match.ast[*-1].key, "endline", "Last is endline";
}

{
    my $music = q«X:044
T:Elsie Marley
B:Robin Williamson, "Fiddle Tunes" (New York 1976)
N:"printed by Robert Petrie in 1796 and is
N:"described by him as a 'bumpkin'."
Z:Nigel Gatherer
M:6/8
L:1/8
K:G
BAB G2G|G2g gdc|BAB G2G|=F2f fcA|
BAB G2G|G2g gdB|c2a B2g|A2=f fcA:|
»;

    my $match = ABC::Grammar.parse($music, :rule<tune>, :actions(ABC::Actions.new));
    ok $match, 'tune recognized';
    isa_ok $match.ast, ABC::Tune, 'and ABC::Tune created';
    ok $match.ast.header.is-valid, "ABC::Tune's header is valid";
    is $match.ast.music.elems, 57, '$match.ast.music has 57 elements';
}

{
    my $match = ABC::Grammar.parse(slurp("samples.abc"), :rule<tune_file>, :actions(ABC::Actions.new));
    ok $match, 'samples.abc is a valid tune file';
    # say $match.ast.perl;
    is @( $match<tune> ).elems, 3, "Three tunes were found";
    # is @( $match.ast )[0].elems, 3, "Three tunes were found";
    isa_ok @( $match.ast )[0][0], ABC::Tune, "First is an ABC::Tune";
}

{
    my $music = q«X:1
T:Canon in D
C:Pachelbel
M:2/2
L:1/8
K:D
"D" DFAd "A" CEAc|"Bm" B,DFB "F#m" A,CFA|"G" B,DGB "D" A,DFA|"G" B,DGB "A" CEAc|
"D" f4 "A" e4|"Bm" d4 "F#m" c4|"G" B4 "D" A4|"G" B4 "A" c4|»;
    my $match = ABC::Grammar.parse($music, :rule<tune_file>, :actions(ABC::Actions.new));
    isa_ok $match, Match, 'Got a match';
    ok $match, 'tune_file recognized';
    
    is $match<tune>.elems, 1, 'found one tune';
    is $match<tune>[0]<music><line_of_music>.elems, 2, "with two lines of music";
}


done;
