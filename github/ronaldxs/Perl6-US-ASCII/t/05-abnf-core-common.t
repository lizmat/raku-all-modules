use v6.c;
use Test;
use US-ASCII::ABNF::Core :common;

plan 3;

my $latin-chars = [~] chr(0)..chr(0xFF);

is $latin-chars.comb(/<ALPHA>/).join, ('A'..'Z', 'a'..'z').flat.join,
    'import ALPHA';
is $latin-chars.comb(/<BIT>/).join, '01',
    'import BIT';
throws-like { '"' ~~ /<DQUOTE>/ }, X::Method::NotFound,
    'not import DQUOTE with common';

