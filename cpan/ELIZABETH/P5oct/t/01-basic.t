use v6.c;
use Test;
use P5oct;

plan 14;

ok defined(::('&oct')),       'is &oct imported?';
ok !defined(P5oct::{'&oct'}), 'is &oct externally NOT accessible?';

for <11 0o11 0011 11.576> {
    is oct($_), 9, "did $_ explicitely get handled ok";
    is oct,     9, "did $_ implicitely get handled ok";
}

for <0x11> {
    is oct($_), 17, 'did 0x explicitely get handled ok';
    is oct,     17, 'did 0x implicitely get handled ok';
}

for <0b11> {
    is oct($_), 3, 'did 0b explicitely  get handled ok';
    is oct,     3, 'did 0b implicitely  get handled ok';
}

# vim: ft=perl6 expandtab sw=4
