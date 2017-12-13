unit module SQL;
use v6;
use SQL::Lexer;

grammar Basic is Lexer {
    rule TOP {
        \s*
        [   <comment>
         || <statement> <semicolon>
        ] +
    }
    rule statement {
        <drop-statement>
     || <generic-statement>
    }
    rule drop-statement {
        DROP [ <keyword> ]+ <regular-identifier>
    }
    rule generic-statement {
        <keyword>
        [
            <regular-identifier>
          | <keyword>
          | <quoted-label>
          | <period>
          | <literal>
          | <left-paren>
          | <right-paren>
          | <comma>
          | <operator-symbol>
          | <comment>
        ]*
    }
}
