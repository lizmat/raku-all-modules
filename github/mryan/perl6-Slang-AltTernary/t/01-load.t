use v6.c;
use Test;

plan 1;

use-ok("Slang::AltTernary");
# use-ok("Slang::AltTernary:ver<0.2>:auth<github:mryan>");

# Single regex is exported.
# is ~('一' ~~ /<single-kazu>/), "一";

# Grammar is exported
# isnt Kazu.parse('一千九百二十三'), Any;

