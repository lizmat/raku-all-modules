use v6;
use Test;
use ABC::Grammar;

{
    my $match = ABC::Grammar.parse('"Cmin"', :rule<chord_or_text>);
    isa_ok $match, Match, 'Got a match';
    ok $match,  '"Cmin" is a chord';
    is $match<chord>, "Cmin", '"Cmin" is chord Cmin';
    is $match<chord>[0]<basenote>, "C", '"Cmin" has base note C';
    is $match<chord>[0]<chord_type>, "min", '"Cmin" has chord_type "min"';
}

{
    my $match = ABC::Grammar.parse("^A,", :rule<pitch>);
    isa_ok $match, Match, 'Got a match';
    ok $match,  '"^A," is a pitch';
    is $match<basenote>, "A", '"^A," has base note A';
    is $match<octave>, ",", '"^A," has octave ","';
    is $match<accidental>, "^", '"^A," has accidental "#"';
}

{
    my $match = ABC::Grammar.parse("_B", :rule<pitch>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"_B" is a pitch';
    is $match<basenote>, "B", '"_B" has base note B';
    is $match<octave>, "", '"_B" has octave ""';
    is $match<accidental>, "_", '"_B" has accidental "_"';
}

{
    my $match = ABC::Grammar.parse("C''", :rule<pitch>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"note" is a pitch';
    is $match<basenote>, "C", '"note" has base note C';
    is $match<octave>, "''", '"note" has octave two-upticks';
    is $match<accidental>, "", '"note" has accidental ""';
}

{
    my $match = ABC::Grammar.parse("=d,,,", :rule<pitch>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"=d,,," is a pitch';
    is $match<basenote>, "d", '"=d,,," has base note d';
    is $match<octave>, ",,,", '"=d,,," has octave ",,,"';
    is $match<accidental>, "=", '"=d,,," has accidental "="';
}

{
    my $match = ABC::Grammar.parse("2", :rule<note_length>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"2" is a note length';
    is $match, "2", '"2" has note length 2';
}

{
    my $match = ABC::Grammar.parse("^^e2", :rule<mnote>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"^^e2" is a note';
    is $match<pitch><basenote>, "e", '"^^e2" has base note e';
    is $match<pitch><octave>, "", '"^^e2" has octave ""';
    is $match<pitch><accidental>, "^^", '"^^e2" has accidental "^^"';
    is $match<note_length>, "2", '"^^e2" has note length 2';
}

{
    my $match = ABC::Grammar.parse("__f'/", :rule<mnote>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"__f/" is a note';
    is $match<pitch><basenote>, "f", '"__f/" has base note f';
    is $match<pitch><octave>, "'", '"__f/" has octave tick';
    is $match<pitch><accidental>, "__", '"__f/" has accidental "__"';
    is $match<note_length>, "/", '"__f/" has note length /';
}

{
    my $match = ABC::Grammar.parse("G,2/3", :rule<mnote>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"G,2/3" is a note';
    is $match<pitch><basenote>, "G", '"G,2/3" has base note G';
    is $match<pitch><octave>, ",", '"G,2/3" has octave ","';
    is $match<pitch><accidental>, "", '"G,2/3" has no accidental';
    is $match<note_length>, "2/3", '"G,2/3" has note length 2/3';
}

{
    my $match = ABC::Grammar.parse("z2/3", :rule<rest>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"z2/3" is a rest';
    is $match<rest_type>, "z", '"z2/3" has base rest z';
    is $match<note_length>, "2/3", '"z2/3" has note length 2/3';
}

{
    my $match = ABC::Grammar.parse("y/3", :rule<rest>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"y/3" is a rest';
    is $match<rest_type>, "y", '"y/3" has base rest y';
    is $match<note_length>, "/3", '"y/3" has note length 2/3';
}

{
    my $match = ABC::Grammar.parse("x", :rule<rest>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"x" is a rest';
    is $match<rest_type>, "x", '"x" has base rest x';
    is $match<note_length>, "", '"x" has no note length';
}

{
    my $match = ABC::Grammar.parse("+trill+", :rule<element>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"+trill+" is an element';
    is $match<gracing>, "+trill+", '"+trill+" gracing is +trill+';
}

{
    my $match = ABC::Grammar.parse("~", :rule<element>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"~" is an element';
    is $match<gracing>, "~", '"~" gracing is ~';
}

{
    my $match = ABC::Grammar.parse("z/", :rule<element>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"z/" is an element';
    is $match<rest><rest_type>, "z", '"z/" has base rest z';
    is $match<rest><note_length>, "/", '"z/" has length "/"';
}

{
    my $match = ABC::Grammar.parse("(", :rule<element>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"(" is an element';
    is $match<slur_begin>, '(', '"(" is a slur begin';
}

{
    my $match = ABC::Grammar.parse(")", :rule<element>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '")" is an element';
    is $match<slur_end>, ')', '")" is a slur end';
}

{
    my $match = ABC::Grammar.parse("_D,5/4", :rule<element>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"_D,5/4" is an element';
    is $match<stem><mnote>[0]<pitch><basenote>, "D", '"_D,5/4" has base note D';
    is $match<stem><mnote>[0]<pitch><octave>, ",", '"_D,5/4" has octave ","';
    is $match<stem><mnote>[0]<pitch><accidental>, "_", '"_D,5/4" is flat';
    is $match<stem><mnote>[0]<note_length>, "5/4", '"_D,5/4" has note length 5/4';
}

{
    my $match = ABC::Grammar.parse("A>^C'", :rule<broken_rhythm>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"A>^C" is a broken rhythm';
    is $match<stem>[0]<mnote>[0]<pitch><basenote>, "A", 'first note is A';
    is $match<stem>[0]<mnote>[0]<pitch><octave>, "", 'first note has no octave';
    is $match<stem>[0]<mnote>[0]<pitch><accidental>, "", 'first note has no accidental';
    is $match<stem>[0]<mnote>[0]<note_length>, "", 'first note has no length';
    is $match<broken_rhythm_bracket>, ">", 'angle is >';
    is $match<stem>[1]<mnote>[0]<pitch><basenote>, "C", 'second note is C';
    is $match<stem>[1]<mnote>[0]<pitch><octave>, "'", 'second note has octave tick';
    is $match<stem>[1]<mnote>[0]<pitch><accidental>, "^", 'second note is sharp';
    is $match<stem>[1]<mnote>[0]<note_length>, "", 'second note has no length';
}

{
    my $match = ABC::Grammar.parse("d'+p+<<<+accent+_B", :rule<broken_rhythm>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"d+p+<<<+accent+_B" is a broken rhythm';
    given $match
    {
        is .<stem>[0]<mnote>[0]<pitch><basenote>, "d", 'first note is d';
        is .<stem>[0]<mnote>[0]<pitch><octave>, "'", 'first note has an octave tick';
        is .<stem>[0]<mnote>[0]<pitch><accidental>, "", 'first note has no accidental';
        is .<stem>[0]<mnote>[0]<note_length>, "", 'first note has no length';
        is .<g1>[0], "+p+", 'first gracing is +p+';
        is .<broken_rhythm_bracket>, "<<<", 'angle is <<<';
        is .<g2>[0], "+accent+", 'second gracing is +accent+';
        is .<stem>[1]<mnote>[0]<pitch><basenote>, "B", 'second note is B';
        is .<stem>[1]<mnote>[0]<pitch><octave>, "", 'second note has no octave';
        is .<stem>[1]<mnote>[0]<pitch><accidental>, "_", 'second note is flat';
        is .<stem>[1]<mnote>[0]<note_length>, "", 'second note has no length';
    }
}

{
    my $match = ABC::Grammar.parse("(3abc", :rule<tuplet>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"(3abc" is a tuplet';
    is ~$match, "(3abc", '"(3abc" was the portion matched';
    is +@( $match<stem> ), 3, 'Three notes matched';
    is $match<stem>[0], "a", 'first note is a';
    is $match<stem>[1], "b", 'second note is b';
    is $match<stem>[2], "c", 'third note is c';
}

{
    my $match = ABC::Grammar.parse("(5abcde", :rule<tuplet>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"(5abcde" is a tuplet';
    is ~$match, "(5abcde", '"(5abcde" was the portion matched';
    is +@( $match<stem> ), 5, 'Three notes matched';
    is $match<stem>[0], "a", 'first note is a';
    is $match<stem>[1], "b", 'second note is b';
    is $match<stem>[2], "c", 'third note is c';
    is $match<stem>[3], "d", 'fourth note is d';
    is $match<stem>[4], "e", 'fifth note is e';
}

{
    my $match = ABC::Grammar.parse("[a2bc]3", :rule<stem>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"[a2bc]3" is a stem';
    is ~$match, "[a2bc]3", '"[a2bc]3" was the portion matched';
    is +@( $match<mnote> ), 3, 'Three notes matched';
    is $match<mnote>[0], "a2", 'first note is a2';
    is $match<mnote>[1], "b", 'second note is b';
    is $match<mnote>[2], "c", 'third note is c';
    is $match<note_length>, "3", 'correct duration';
    nok ?$match<tie>, 'not tied';
}

{
    my $match = ABC::Grammar.parse("[a2bc]3-", :rule<stem>);
    isa_ok $match, Match, 'Got a match';
    ok $match, '"[a2bc]3-" is a stem';
    is ~$match, "[a2bc]3-", '"[a2bc]3-" was the portion matched';
    is +@( $match<mnote> ), 3, 'Three notes matched';
    is $match<mnote>[0], "a2", 'first note is a2';
    is $match<mnote>[1], "b", 'second note is b';
    is $match<mnote>[2], "c", 'third note is c';
    is $match<note_length>, "3", 'correct duration';
    ok ?$match<tie>, 'tied';
}

# (3 is the only case that works currently.  :(
# {
#     my $match = ABC::Grammar.parse("(2abcd", :rule<tuple>);
#     isa_ok $match, Match, '"(2ab" is a tuple';
#     is ~$match, "(2ab", '"(2ab" was the portion matched';
#     is $match<stem>[0], "a", 'first note is a';
#     is $match<stem>[1], "b", 'second note is b';
# }

for ':|:', '|:', '|', ':|', '::', '|]' 
{
    my $match = ABC::Grammar.parse($_, :rule<barline>);
    isa_ok $match, Match, 'Got a match';
    ok $match, "barline $_ recognized";
    is $match, $_, "barline $_ is correct";
}

{
    my $match = ABC::Grammar.parse("g>ecgece/f/g/e/|", :rule<bar>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'bar recognized';
    is $match, "g>ecgece/f/g/e/|", "Entire bar was matched";
    is $match<element>.for(~*), "g>e c g e c e/ f/ g/ e/", "Each element was matched";
    is $match<barline>, "|", "Barline was matched";
}

{
    my $match = ABC::Grammar.parse("g>ecg ec e/f/g/e/ |", :rule<bar>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'bar recognized';
    is $match, "g>ecg ec e/f/g/e/ |", "Entire bar was matched";
    is $match<element>.for(~*), "g>e c g   e c   e/ f/ g/ e/  ", "Each element was matched";
    is $match<barline>, "|", "Barline was matched";
}

{
    my $line = "g>ecg ec e/f/g/e/ | d/c/B/A/ Gd BG B/c/d/B/ |";
    my $match = ABC::Grammar.parse($line, :rule<line_of_music>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'line of music recognized';
    is $match, $line, "Entire line was matched";
    is $match<bar>[0], "g>ecg ec e/f/g/e/ |", "First bar is correct";
    is $match<bar>[1], " d/c/B/A/ Gd BG B/c/d/B/ |", "Second bar is correct";
    # say $match<ABC::Grammar::line_of_music>.perl;
}

{
    my $line = "g>ecg ec e/f/g/e/ |1 d/c/B/A/ Gd BG B/c/d/B/ |";
    my $match = ABC::Grammar.parse($line, :rule<line_of_music>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'line of music recognized';
    is $match, $line, "Entire line was matched";
    is $match<bar>[0], "g>ecg ec e/f/g/e/ |", "First bar is correct";
    is $match<bar>[1], "1 d/c/B/A/ Gd BG B/c/d/B/ |", "Second bar is correct, even with stupid hacky |1 ending marker";
    # say $match<ABC::Grammar::line_of_music>.perl;
}

{
    my $line = "|A/B/c/A/ c>d e>deg | dB/A/ gB +trill+A2 +trill+e2 ::";
    my $match = ABC::Grammar.parse($line, :rule<line_of_music>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'line of music recognized';
    is $match, $line, "Entire line was matched";
    is $match<bar>[0], "A/B/c/A/ c>d e>deg |", "First bar is correct";
    is $match<bar>[1], " dB/A/ gB +trill+A2 +trill+e2 ::", "Second bar is correct";
    is $match<barline>, "|", "Initial barline matched";
    # say $match<ABC::Grammar::line_of_music>.perl;
}

{
    my $line = 'g>ecg ec e/f/g/e/ |[2-3 d/c/B/A/ {Gd} BG B/c/d/B/ |';
    my $match = ABC::Grammar.parse($line, :rule<line_of_music>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'line of music recognized';
    is $match, $line, "Entire line was matched";
    is $match<bar>[0], "g>ecg ec e/f/g/e/ |", "First bar is correct";
    is $match<bar>[1], '[2-3 d/c/B/A/ {Gd} BG B/c/d/B/ |', "Second bar is correct";
    # say $match<ABC::Grammar::line_of_music>.perl;
}

{
    my $match = ABC::Grammar.parse("[K:F]", :rule<inline_field>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'inline field recognized';
    is $match, "[K:F]", "Entire string was matched";
    is $match<alpha>, "K", "Correct field name found";
    is $match<value>, "F", "Correct field value found";
}

{
    my $match = ABC::Grammar.parse("[M:3/4]", :rule<inline_field>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'inline field recognized';
    is $match, "[M:3/4]", "Entire string was matched";
    is $match<alpha>, "M", "Correct field name found";
    is $match<value>, "3/4", "Correct field value found";
}

{
    my $match = ABC::Grammar.parse(" % this is a comment", :rule<comment_line>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'comment line recognized';
    is $match, " % this is a comment", "Entire string was matched";
}

{
    my $match = ABC::Grammar.parse("% this is a comment", :rule<comment_line>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'comment line recognized';
    is $match, "% this is a comment", "Entire string was matched";
}

{
    my $line = "g>ecg ec e/f/g/e/ | d/c/B/A/ [K:F] Gd BG B/c/d/B/ |";
    my $match = ABC::Grammar.parse($line, :rule<line_of_music>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'line of music recognized';
    is $match, $line, "Entire line was matched";
    is $match<bar>[0], "g>ecg ec e/f/g/e/ |", "First bar is correct";
    is $match<bar>[1], " d/c/B/A/ [K:F] Gd BG B/c/d/B/ |", "Second bar is correct";
    ok @( $match<bar>[1]<element> ).grep("[K:F]"), "Key change got recognized";
    # say $match<ABC::Grammar::line_of_music>.perl;
}

{
    my $line = "g>ecg ec e/f/g/e/ | d/c/B/A/ [M:C] Gd BG B/c/d/B/ |";
    my $match = ABC::Grammar.parse($line, :rule<line_of_music>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'line of music recognized';
    is $match, $line, "Entire line was matched";
    is $match<bar>[0], "g>ecg ec e/f/g/e/ |", "First bar is correct";
    is $match<bar>[1], " d/c/B/A/ [M:C] Gd BG B/c/d/B/ |", "Second bar is correct";
    ok @( $match<bar>[1]<element> ).grep("[M:C]"), "Meter change got recognized";
    # say $match<ABC::Grammar::line_of_music>.perl;
}

{
    my $line = "| [K:F] Gd BG [B/c/d/B/]|";
    my $match = ABC::Grammar.parse($line, :rule<line_of_music>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'line of music recognized';
    is $match, $line, "Entire line was matched";
    is $match<bar>[0]<element>[1], "[K:F]", "Key signature change is correctly captured";
    # is $match<bar>[1], " d/c/B/A/ [K:F] Gd BG B/c/d/B/ |", "Second bar is correct";
}

{
    my $line = 'E2 CE GCEG|c4 B3 ^F|(A2 G2) =F2 D2|C4 {B,C}E2 D>E|[1 (D4 C2) z2:|[2 (D4 C2) z3/2 [G/2D/2]|';
    my $match = ABC::Grammar.parse($line, :rule<line_of_music>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'line of music recognized';
    is $match, $line, "Entire line was matched";
    is $match<bar>[5]<element>[0], "[2", "nth repeat works";
}

{
    my $music = q«A/B/c/A/ +trill+c>d e>deg | GG +trill+B>c d/B/A/G/ B/c/d/B/ |
    A/B/c/A/ c>d e>deg | dB/A/ gB +trill+A2 +trill+e2 ::
    g>ecg ec e/f/g/e/ | d/c/B/A/ Gd BG B/c/d/B/ | 
    g/f/e/d/ c/d/e/f/ gc e/f/g/e/ | dB/A/ gB +trill+A2 +trill+e2 :|»;
    my $match = ABC::Grammar.parse($music, :rule<music>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'music recognized';
    is $match<line_of_music>.elems, 4, "Four lines matched";
}

{
    my $music = q«% Comment
X:64
T:Cuckold Come Out o' the Amrey
S:Northumbrian Minstrelsy
M:4/4
L:1/8
K:D
»;
    my $match = ABC::Grammar.parse($music, :rule<header>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'header recognized';
    is $match<header_field>.elems, 6, "Six fields matched";
    is $match<header_field>.for({ .<header_field_name> }), "X T S M L K", "Got the right field names";
}

{
    my $music = q«X:64
T:Cuckold Come Out o' the Amrey
S:Northumbrian Minstrelsy
M:4/4
L:1/8
K:D
A/B/c/A/ +trill+c>d e>deg | GG +trill+B>c d/B/A/G/ B/c/d/B/ |
A/B/c/A/ c>d e>deg | dB/A/ gB +trill+A2 +trill+e2 :: % test comment
g>ecg ec e/f/g/e/ | d/c/B/A/ Gd BG B/c/d/B/ | 
g/f/e/d/ c/d/e/f/ gc e/f/g/e/ | dB/A/ gB +trill+A2 +trill+e2 :|
»;
    my $match = ABC::Grammar.parse($music, :rule<tune>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'tune recognized';
    given $match<header>
    {
        is .<header_field>.elems, 6, "Six fields matched";
        is .<header_field>.for({ .<header_field_name> }), "X T S M L K", "Got the right field names";
    }
    is $match<music><line_of_music>.elems, 4, "Four lines matched";
}

{
    my $music = q«X:1
T:Are You Coming From The Races?
O:from the playing of Frank Maher
M:2/4
L:1/8
R:Single
K:D
DE|:F2 F2|AF ED|E2 EF|ED DE|F2 F2|AF ED|E2 D2|
|[1 D2 DE:|[2 D2 dc|:B2 Bc|BA FG|AB AF|
AF dc|B2 Bc|BA FA|B2 A2|[1 A2 dc:|[2 A2

X:2
T:Bride's Jig
O:from the playing of Frank Maher
M:2/4
L:1/8
R:Single
K:Edor
|:B E2 G|FE D2|E>F GA|Bc BA|B E2 G|FE D2|E>F GE|A2 A2:|
|:AB cd|e4|AB cB|BA FA|AB cd|e4|AB cB|A2 A2:|
»;
    my $match = ABC::Grammar.parse($music, :rule<tune_file>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'tune_file recognized';
    
    is $match<tune>.elems, 2, 'found two tunes';
    is $match<tune>[0]<music><line_of_music>.elems, 3;
    is $match<tune>[1]<music><line_of_music>.elems, 2;
}

{
    my $music = q«X:1
T:Are You Coming From The Races?
O:from the playing of Frank Maher
M:2/4
L:1/8
R:Single
K:D
DE|:F2 F2|AF ED|E2 EF|ED DE|F2 F2|AF ED|E2 D2|
|[1 D2 DE:|[2 D2 dc|:B2 Bc|BA FG|AB AF|
AF dc|B2 Bc|BA FA|B2 A2|[1 A2 dc:|[2 A2

X:2
T:Bride's Jig
O:from the playing of Frank Maher
M:2/4
L:1/8
R:Single
K:Edor
|:B E2 G|FE D2|E>F GA|Bc BA|B E2 G|FE D2|E>F GE|A2 A2:|
|:AB cd|e4|AB cB|BA FA|AB cd|e4|AB cB|A2 A2:|»;
    my $match = ABC::Grammar.parse($music, :rule<tune_file>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'tune_file recognized';
    
    is $match<tune>.elems, 2, 'found two tunes';
    is $match<tune>[0]<music><line_of_music>.elems, 3;
    is $match<tune>[1]<music><line_of_music>.elems, 2;
}

{
    my $music = q«X:1
T:Canon in D
C:Pachelbel
M:2/2
L:1/8
K:D
"D" DFAd "A" CEAc|"Bm" B,DFB "F#m" A,CFA|"G" B,DGB "D" A,DFA|"G" B,DGB "A" CEAc|
"D" f4 "A" e4|"Bm" d4 "F#m" c4|"G" B4 "D" A4|"G" B4 "A" c4|
»;
    my $match = ABC::Grammar.parse($music, :rule<tune_file>);
    isa_ok $match, Match, 'Got a match';
    ok $match, 'tune_file recognized';
    
    is $match<tune>.elems, 1, 'found one tune';
    is $match<tune>[0]<music><line_of_music>.elems, 2, "with two lines of music";
}

done;
