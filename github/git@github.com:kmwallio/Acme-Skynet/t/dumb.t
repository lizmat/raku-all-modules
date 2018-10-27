use v6;
use lib 'lib';
use Test;
use Acme::Skynet::DumbDown;

plan 8;
# Test one plural word
ok dumbdown("cats") eq "cat", "Strips plural";

# Phrase
ok dumber("the kids have cats") eq "the kid have cat", "Handles multiple words";

# Multi-Level Dumbing Down
ok dumbdown("computers") eq "comput", "Rootification";

# Example
ok dumber('he eats cats') eq "he eat cat", "Moar tests";

# Decontracted
ok extraDumbedDown("we're so cool") eq "we ar so cool", "Decontract";
ok extraDumbedDown("what's the current o'clock") eq "what is the current of the clock", "Multiple decontract";

# Labeled
ok labeledDumbdown("he eats cats").elems == 2, "Original, Modified";
ok labeledExtraDumbedDown("we're so cool").elems == 2, "Original, Modified";

done-testing;
