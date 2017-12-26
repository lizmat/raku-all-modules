use v6;
use Test;

use SQL::Lexer;

my @good-literals = (
    Q/124/      => 'unsigned-numeric-literal',
    Q/12.4/     => 'unsigned-numeric-literal',
    Q/+12.4/    => 'signed-numeric-literal',
    Q/-12.4/    => 'signed-numeric-literal',
    Q/-0/       => 'signed-numeric-literal',
    Q/+1/       => 'signed-numeric-literal',
    Q/'abc'/    => 'char-string-literal',
    Q/'ab cd '/ => 'char-string-literal',
    Q/'ab"cd '/ => 'char-string-literal',
    Q/'ab''c'/  => 'char-string-literal',
    Q/"abc"/    => 'char-string-literal',
    Q/"ab""c"/  => 'char-string-literal',
    Q/"ab''c"/  => 'char-string-literal',
    Q/""""/     => 'char-string-literal',
    Q/''/       => 'char-string-literal',
    Q/TRUE/     => 'boolean-literal',
    Q/FALSE/    => 'boolean-literal',
);

my @bad-literals = (
    Q/12a4/,
    Q/12.34.56/,
    Q/e12/,
    Q/-+0/,
    Q/1,002/,
    Q/'a'b'/,
    Q/'abc"/,
    Q/"def'/,
);

for @good-literals {
    ok SQL::Lexer.parse( .key, :rule<literal> ), "Good literal: |{ .key }|";
    ok SQL::Lexer.parse( .key, :rule(.value) ), "Correct type: { .value }";
}

nok SQL::Lexer.parse( $_, :rule<literal> ), "Bad literal: |$_|"
    for @bad-literals;

done-testing;
