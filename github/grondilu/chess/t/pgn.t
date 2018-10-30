use Chess::PGN;

use Test;
plan 8;

ok Chess::PGN.parse('1. e4'), "simple first move";
ok Chess::PGN.parse('2... e5'), "black to move";
ok Chess::PGN.parse('1. e4 d5 2. exd5'), "scandinavian";
ok Chess::PGN.parse('1. e4 d5 2. e5 f5 3. exf5ep'), "en passant";
ok Chess::PGN.parse('1. e4 e5 2. f4 Qh4+'), "simple check";
ok Chess::PGN.parse('1. e4 g5 2. d4 f5 3. Qh5#'), "dumb mate";
ok Chess::PGN.parse('1. e4 g5?! 2. d4 f5?? 3. Qh5#'), "dumb mate with comments";
ok Chess::PGN.parse('1. e4 g5?! 2. d4 f5?? 3. Qh5# 1-0'), "dumb mate with adjudication";


# vim: ft=perl6
