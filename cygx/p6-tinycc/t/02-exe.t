#!/usr/bin/env perl6

use v6;

use Test;
use TinyCC;

tcc.set(:L<.>).target(:EXE);
tcc.compile(q:to/__END__/);
    int main(void) { return 42; }
    __END__

my $exe = 'test-42.exe';
tcc.dump($exe);
ok run("./$exe") == 42, 'exe returned 42';
unlink $exe;

done;
