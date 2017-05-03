#!/usr/bin/env perl6
use v6;
use Test;
plan 1;
use C::Parser::Grammar;

our $source = q<<<
    int main() {
        puts("Hello World!");
        return 0;
    }
>>>;

{
    my $match = C::Parser::Grammar.parse($source);
    isa-ok($match, C::Parser::Grammar, 'gives a Grammar');
}
