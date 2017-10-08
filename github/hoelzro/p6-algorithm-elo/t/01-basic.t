use v6;
use Test;

use Algorithm::Elo;

plan 12;

my $player-a;
my $player-b;

( $player-a, $player-b ) = calculate-elo(1_600, 1_600, :left);

is $player-a, 1_616;
is $player-b, 1_584;

( $player-a, $player-b ) = calculate-elo(1_600, 1_600, :right);

is $player-a, 1_584;
is $player-b, 1_616;

( $player-a, $player-b ) = calculate-elo(1_600, 1_600, :draw);

is $player-a, 1_600;
is $player-b, 1_600;

( $player-a, $player-b ) = calculate-elo(2_000, 1_000, :left);

is $player-a, 2_000;
is $player-b, 1_000;

( $player-a, $player-b ) = calculate-elo(2_000, 1_000, :right);

is $player-a, 1_968;
is $player-b, 1_032;

( $player-a, $player-b ) = calculate-elo(2_000, 1_000, :draw);

is $player-a, 1984;
is $player-b, 1016;
