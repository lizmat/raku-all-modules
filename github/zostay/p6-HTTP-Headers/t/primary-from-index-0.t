#!perl6

use v6;

use Test;
use HTTP::Headers;

my $h = HTTP::Headers.new;

is $h.Content-Type.primary, Str, 'primary from empty is Str';

done-testing;
