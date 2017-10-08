use v6;
use Test;
plan 5;

use Text::Emotion::Scorer;

{
    my $scorer = Text::Emotion::Scorer.new;
    say $scorer.WHAT.perl;
    isa-ok $scorer, Text::Emotion::Scorer;
    ok $scorer.score_word('abhors') == -3, "'abhors' is scored as -3";
    ok $scorer.score_word('yummy') == 3, "'yummy' is scored as 3";
    ok $scorer.score('I abhor these yummy treats') == 0, "'I abhor these yummy treats' is scored as 0";
    ok $scorer.score('Yay yummy treats') == 3, "'Yay yummy treats' is scored as 3";
}

done-testing;
