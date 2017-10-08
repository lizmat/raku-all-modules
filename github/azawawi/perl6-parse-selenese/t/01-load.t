use v6;

use Test;

plan 2;

use Parse::Selenese;
ok 1, "'use Parse::Selenese' worked!";
ok Parse::Selenese.new, "Parse::Selenese.new worked";
