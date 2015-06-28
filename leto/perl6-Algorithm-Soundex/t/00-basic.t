use v6;
use Test;

# because prove -l doesn't work for perl 6 modules
BEGIN { unshift @*INC, './lib'; }

plan 4;

use Algorithm::Soundex;
pass("Loaded Algorithm::Soundex");

my Algorithm::Soundex $s .= new();

isa-ok($s, Algorithm::Soundex);

my $soundex = $s.soundex("Robert");
is($soundex, 'R163', 'soundex of Robert');

$soundex = $s.soundex("");
is($soundex, '', 'soundex of nothing is nothing');

