#!/usr/bin/env perl6
use App::Lang::French::VerbTrainer;

sub MAIN(ValidFrenchVerb $verb) {
    say "Press Ctrl+C to exit. Type '?' as the answer if you don't know it";
    given App::Lang::French::VerbTrainer.new: :$verb {
        .ask: 'Présent',       .présent;
        .ask: 'Future proche', .future-proche;
        .ask: 'Imparfait',     .imparfait;
        .ask: 'Passé composé', .passé-composé;
    }
}
