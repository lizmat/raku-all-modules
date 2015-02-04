use v6;
use Test;
use ABC::Context;
use ABC::Grammar;
use ABC::Actions;

{
    my $context = ABC::Context.new("C", "4/4", "1/8");
    
    my $match = ABC::Grammar.parse("abcdefgab^c_dcd", :rule<bar>, :actions(ABC::Actions.new));
    isa_ok $match, Match, 'Got a match';
    ok $match, 'bar recognized';
    
    # first run loads up C# and Db
    for @($match.ast) Z ("" xx 9, "^", "_", "^", "_") -> $note, $desired-accidental {
        my $accidental = $context.working-accidental($note.value);
        is $accidental, $desired-accidental;
    }
    
    # second run still has them
    for @($match.ast) Z ("", "", "^", "_", "", "", "", "", "", "^", "_", "^", "_") -> $note, $desired-accidental {
        my $accidental = $context.working-accidental($note.value);
        is $accidental, $desired-accidental;
    }

    $context.bar-line;

    # and now we've reset to the initial state
    for @($match.ast) Z ("" xx 9, "^", "_", "^", "_") -> $note, $desired-accidental {
        my $accidental = $context.working-accidental($note.value);
        is $accidental, $desired-accidental;
    }
}

{
    my $context = ABC::Context.new("C#", "4/4", "1/8");
    
    my $match = ABC::Grammar.parse("abcdefgab^c_dcd", :rule<bar>, :actions(ABC::Actions.new));
    isa_ok $match, Match, 'Got a match';
    ok $match, 'bar recognized';
    
    # first run loads up C# and Db
    for @($match.ast) Z ("^" xx 9, "^", "_", "^", "_") -> $note, $desired-accidental {
        my $accidental = $context.working-accidental($note.value);
        is $accidental, $desired-accidental;
    }
    
    # second run still has them
    for @($match.ast) Z ("^", "^", "^", "_", "^", "^", "^", "^", "^", "^", "_", "^", "_") -> $note, $desired-accidental {
        my $accidental = $context.working-accidental($note.value);
        is $accidental, $desired-accidental;
    }

    $context.bar-line;

    # and now we've reset to the initial state
    for @($match.ast) Z ("^" xx 9, "^", "_", "^", "_") -> $note, $desired-accidental {
        my $accidental = $context.working-accidental($note.value);
        is $accidental, $desired-accidental;
    }
}

done;