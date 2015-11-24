#!/usr/bin/env perl6

use v6;

use Test;
use TinyCC *;

plan 2;

ok tcc.compile('int main(void) { return -42; }').run == -42, 'can run code';
ok tcc.reuse(:code).run == -42, 'can reuse compiler object';

done-testing;
