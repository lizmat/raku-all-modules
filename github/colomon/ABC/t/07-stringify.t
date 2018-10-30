use v6;
use Test;

use ABC::Grammar;
use ABC::Header;
use ABC::Tune;
use ABC::Duration;
use ABC::Note;
use ABC::Rest;
use ABC::Tuplet;
use ABC::BrokenRhythm;
use ABC::Chord;
use ABC::LongRest;
use ABC::GraceNotes;
use ABC::Actions;
use ABC::Utils;

my @simple-cases = ("a", "B,", "c'''", "^D2-", "_E,,/", "^^f/4", "=G3",
                    "z3", "y/3", "x", "Z10",
                    "[ceg]", "[D3/2d3/2]", "[A,2F2]",
                    "(3abc", "(5A/B/C/D/E/",
                    "a>b", "^c/4<B,,/4",
                    '{cdc}', '{/d}',
                    "(", ")", 
                    " ", "\t ",
                    "]");

my @tricky-cases = ('"A"', '"A/B"', '"Am/Bb"',
                    '"^this goes up"', '"_This goes down"',
                    "+trill+", "+accent+",
                    "[2", ".", "~",
                    "[K:Amin]", "[M:3/4]", "[L:1/2]");

for @simple-cases -> $test-case {
    my $match = ABC::Grammar.parse($test-case, :rule<element>, :actions(ABC::Actions.new));
    ok $match, "$test-case parsed";
    my $object = $match.ast.value;
    # say $object.perl;
    is ~$object, $test-case, "Stringified version matches";
}

for |@simple-cases, |@tricky-cases -> $test-case {
    my $match = ABC::Grammar.parse($test-case, :rule<element>, :actions(ABC::Actions.new));
    ok $match, "$test-case parsed";
    is element-to-str($match.ast), $test-case, "element-to-str version matches";
}

# my @notes = <a b2 c/ d e f g3>.for({ str-to-stem($_) });
# is ABC::Tuplet.new(3, 2, @notes[^2]), "(3::2ab2", "triplet with only two notes";
# is ABC::Tuplet.new(3, 2, @notes[^4]), "(3::4ab2c/d", "triplet with four notes";
# is ABC::Tuplet.new(3, 3, @notes[^4]), "(3:3:4ab2c/d", "triplet with four notes and a weird rhythm";

done-testing;