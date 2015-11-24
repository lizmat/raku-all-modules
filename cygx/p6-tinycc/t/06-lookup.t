#!/usr/bin/env perl6

use v6;

use Test;

plan 4;

{
    use TinyCC *;
    LEAVE tcc.discard;

    tcc.set(:nostdlib);
    tcc.compile(q:to/__END__/);
        void _start() {};
        int i = 42;
        __END__
    tcc.relocate;

    my $p = tcc.lookup('i');
    ok defined($p), 'can lookup declared symbol';

    my $q = tcc.lookup('j');
    ok !defined($q), 'cannot lookup undeclared symbol';

    my $ip = tcc.lookup('i', int32);
    ok $ip.deref == 42, 'can acces value through typed pointer';

    my $i := tcc.lookup('i', var => int32);
    ok $i == 42, 'can access value through proxy variable';
}

done-testing;
