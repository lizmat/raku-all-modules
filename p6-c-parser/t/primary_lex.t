#!/usr/bin/env perl6
use v6;
use Test;
plan 4;
use C::Parser::Lexer;

{
    my $source = q<<< char newline = '\n'; >>>;
    my $ast = C::Parser::Lexer.parse($source);
    isa-ok $ast, Match, 'gives a Match';
}

{
    my $source = q<<< char *name = "world"; >>>;
    my $ast = C::Parser::Lexer.parse($source);
    isa-ok $ast, Match, 'gives a Match';
}

{
    my $source = q<<< int number = 5; >>>;
    my $ast = C::Parser::Lexer.parse($source);
    isa-ok $ast, Match, 'gives a Match';

    #my @tokens = $ast{'c-tokens'}{'c-token'};
    #say @tokens.perl;
    #say @tokens;
    #is @tokens[0]<keyword>, 'char ',     '1st token';
    #is @tokens[1], 'newline ',  '2nd token';
    #is @tokens[2], '= ',        '3rd token';
    #is @tokens[3], "'\n'",		'4th token';
    #is @tokens[4], ";\n",		'5th token';
}

{
    my $source = q<<< double pi64 = 3.14; >>>;
    my $ast = C::Parser::Lexer.parse($source);
    isa-ok $ast, Match, 'gives a Match';
}
