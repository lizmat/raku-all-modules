# Chess

Chess-related stuff in Perl 6

## PGN Grammar

    use Chess::PGN;
    say Chess::PGN.parse: "1. f3 e5 2. g4?? Qh4#";

## FEN Grammar

    use Chess::FEN;
    say Chess::FEN.parse('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');

See L<http://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation> for more information.
