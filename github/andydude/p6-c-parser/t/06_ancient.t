#!/usr/bin/env perl6
use v6;
use Test;
plan 1;
use C::AST;
use C::Parser;

our $source = q<<<
    int printf(const char *, ...);
    
    int main(argc, argv)
        int argc; char * argv[];
    {
        printf("Hello %s!", argv[1]);
        return 0;
    }
>>>;

{
    my $match = C::Parser.parse($source);
    isa-ok($match, C::AST::TransUnit, 'gives a C::AST::TransUnit');
}
