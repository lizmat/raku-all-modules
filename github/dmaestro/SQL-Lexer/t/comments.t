use v6;
use Test;

use SQL::Lexer;

my @good-comments = (
    "-- a standard single-line comment\n",
    "-- a comment with Unicode »ö«\n",
    "# an extended (unix-style) comment\n",
    "/* a multi-line\n * comment\n */",
    "/* an embedded comment */",
);

my @bad-comments = (
    "-- single-line comment\nover two lines\n",
    "-- single-line comment followed by whitespace\n  ",
);

ok SQL::Lexer.parse(  $_, :rule<comment> ), "Good comment\n$_\n---" for @good-comments;
nok SQL::Lexer.parse( $_, :rule<comment> ), "Bad comment\n$_\n---" for @bad-comments;

done-testing;
