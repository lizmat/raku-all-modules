grammar Chess::FEN;

rule TOP { <board> <active-color> <castling> <en-passant> <half-move-clock> <full-move-number> }

token board { <rank> ** 8 % '/' }
token rank { ( <piece> | <empty-squares> ) ** 1..8 }
token active-color { w | b }
token castling { '-' | < K k Q q > ** 1..4 }
token en-passant { '-' | <file>< 3 6 > }
token half-move-clock { <number>+ }
token full-move-number { <number>+ }
token number { '0' | <[1..9]><digit>* }

token file { < a b c d e f g h > }
token piece { <black-piece> | <white-piece> }
token white-piece { < K Q R B N P > }
token black-piece { < k q r b n p > }
token empty-squares { <[1..8]> }
