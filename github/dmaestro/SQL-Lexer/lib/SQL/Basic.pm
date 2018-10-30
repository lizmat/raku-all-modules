use v6;
use SQL::Lexer;

grammar SQL::Basic:ver<0.2.1> is SQL::Lexer:ver<0.2.1..*> {
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
    rule compound-statement {
        BEGIN
            [   <comment>
             || <statement> <semicolon>
            ] +
    :!s END
    }
    rule drop-statement {
        DROP [ <keyword> ]+ <regular-identifier>
    }
    rule generic-statement {
        <keyword>
        [ <compound-statement>
         || [   <regular-identifier>
              | <keyword>
              | <quoted-label>
              | <variable>
              | <compound-statement>
              | <period>
              | <literal>
              | <left-paren>
              | <right-paren>
              | <comma>
              | <operator-symbol>
              | <comment>
            ]
        ]*
    }
}
