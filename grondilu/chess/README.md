# Chess

Chess-related stuff in Perl 6

## PGN Grammar

    use Chess::PGN;
    say Chess::PGN.parse: "1. f3 e5 2. g4?? Qh4#";

## FEN Grammar

    use Chess::FEN;
    say Chess::FEN.parse('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');

See [the wikipedia article about FEN](http://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation) for more information.

## General utilities

    use Chess;
    show-FEN 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1';

![Hopefully the code above should produce a nice colored representation of the board position](http://i.imgur.com/tbiUqwK.png)


