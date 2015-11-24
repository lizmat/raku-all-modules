#!/usr/bin/env perl6

use v6;
use Test;

use TinyCC *;

plan 2;

my $exe = 'test-42.exe';

tcc.target(:EXE).compile(q:to/__END__/).dump($exe);
    int main(void) { return 42; }
    __END__

pass 'executable compiled successfully';

ok run("./$exe") == 42, 'executable returned expected value';
unlink $exe;

done-testing;
