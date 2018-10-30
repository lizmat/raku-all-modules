use v6;
use Test;

use SQL::Lexer;

my @good-literals = (
    Q/'0000-00-00'/ => 'date-string',
    Q/"2017-12-25"/ => 'date-string',
    Q/'2017-12-00'/ => 'date-string',
    Q/'00:00:00'/ => 'time-string',
    Q/'23:59:59'/ => 'time-string',
    Q/'12:30:00-06:00'/ => 'time-string',
    Q/'6:30:00+04:00'/ => 'time-string',
    Q/'1492-10-12 11:30:21'/ => 'timestamp-string',
    Q/DATE "2017-12-25"/ => 'date-literal',
    Q/TIME '12:30:00-06:00'/ => 'time-literal',
    Q/TIMESTAMP '1492-10-12 11:30:21'/ => 'timestamp-literal',
);

my @bad-literals = (
    Q/DATE "2017-12-25'/,
    Q/DATE 2017-12-25/,
    Q/TIME "2017-12-25"/,
);

for @good-literals {
    ok SQL::Lexer.parse( .key, :rule(.value) ), "Good datetime({ .value }): { .key }";
}

nok SQL::Lexer.parse( $_, :rule<literal> ), "Bad literal: |$_|"
    for @bad-literals;

done-testing;
