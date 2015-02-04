#!/usr/bin/env perl6
use v6;
use Test;
plan 1;
use C::AST;
use C::Parser;

our $source = q<<<
    typedef void * FILE;
    extern int getc (FILE *__stream);
>>>;

{
    my $ast = C::Parser.parse($source);
    isa_ok($ast, C::AST::TransUnit, 'gives a C::AST::TransUnit');
}
