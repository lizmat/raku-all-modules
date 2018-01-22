use v6.c;
use Test;
use Sys::Hostname;

plan 3;

ok defined(::('&hostname')), 'is hostname exported';
isa-ok hostname, Str, 'does it return something Str';
ok hostname.chars, 'does it actually have characters';
