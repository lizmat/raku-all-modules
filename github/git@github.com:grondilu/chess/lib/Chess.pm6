unit module Chess;

use Chess::FEN;

sub show-FEN(Str $fen where Chess::FEN.parse($fen)) is export {
    # set black foreground
    print "\e[30m";
    my %pieces = <k q b n r p K Q B N R P> Z=> <♔ ♕ ♗ ♘ ♖ ♙ ♚ ♛ ♝ ♞ ♜ ♟>;
    for $/<board>.split('/').reverse {
	my $r = $++;
	my @pieces = flat map { /\d/ ?? ' ' xx +$/ !! %pieces{$_} // "?" }, .comb;
	for ^8 -> $c {
	    print ($r + $c) % 2 ?? "\e[100m" !! "\e[47m";
	    print @pieces[$c] // '?';
	}
	print "\n";
    }
    # reset all formating
    print "\e[0m";
}

show-FEN 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
