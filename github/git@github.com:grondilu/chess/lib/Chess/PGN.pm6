unit grammar Chess::PGN;

rule TOP { ^ <game>+? $ }

rule game { <info>* <move>* <adjudication>? }

rule info { '[' ~ ']' [ <tag> <string> ] }
token tag { <.alpha>+ }
token string { '"' .+? '"' }

rule move { <move-number> [ <half-move> <nag> *  <comment> * ] ** 1..2 }
token half-move {
    [
	| <pawn-moves>
	| <pawn-takes>
	| <piece-moves>
	| <piece-takes>
	| <castle>
	| <promotion>
    ]< + ++ # >?<annotation>?
}
token annotation { < ?? ? !? ?! ! !! > }
token nag { '$'<.digit>+ }
rule comment { 
    | '{' .+? '}' 
    | '(' <move>+ ')'
}

token pawn-moves { <square> }
token pawn-takes { <file>'x'<square>'ep'? }
token piece-moves { <piece><disambiguation>??<square> }
token piece-takes { <piece><disambiguation>??'x'<square> }
token castle     { 'O-O' | 'O-O-O' }
token promotion  { [ <pawn-moves> | <pawn-takes> ]'='<piece> }

token disambiguation { <file> | <rank> }

token move-number { <.digit>+< . ... > }

token adjudication { <white-wins> | <black-wins> | <draw> | <aborted-game> }
token white-wins { '1-0' }
token black-wins { '0-1' }
token draw       { '1/2-1/2' }
token aborted-game { '*' }

token piece { < K Q R B N > }
token rank  { < 1 2 3 4 5 6 7 8 > }
token file  { < a b c d e f g h > }
token square { <file><rank> }
