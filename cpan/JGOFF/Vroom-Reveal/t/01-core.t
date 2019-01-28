use v6;
use Test;
use Vroom::Reveal;

plan 1;

ok Vroom::Reveal.to-reveal( '-----\n\nsome text' );

# vim: ft=perl6
