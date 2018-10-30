#!/usr/bin/env perl6

use lib 'lib';
use Slang::Roman;
use Test;

plan 5;

# Start by testing the ASCII equivalents, making sure to do both additive
# and subtractive Roman numerals. The subtractive form wasn't used until
# the 1400s or so, I think.
#
# I'd read somewhere that it was introduced because of clock faces, but that
# sounds like a question for Snopes or the Straight Dope.
#
subtest sub {
  is 0rI, 1, q{Roman numeral 1};
  is 0rII, 2, q{Roman numeral 2};
  is 0rIII, 3, q{Roman numeral 3};
  is 0rIIII, 4, q{Roman numeral 4};
  is 0rV, 5, q{Roman numeral 5};
  is 0rX, 10, q{Roman numeral 10};
  is 0rXI, 11, q{Roman numeral 11};
  is 0rXII, 12, q{Roman numeral 12};
  is 0rL, 50, q{Roman numeral 50};
  is 0rC, 100, q{Roman numeral 100};
  is 0rD, 500, q{Roman numeral 500};
  is 0rM, 1_000, q{Roman numeral 1000};

  subtest sub {
    is 0rIV, 4, q{Roman numeral 4 subtractive};
    is 0rXIV, 14, q{Roman numeral 14 subtractive};
    is 0rXIX, 19, q{Roman numeral 19 subtractive};
    is 0rXLIV, 44, q{Roman numeral 44 subtractive};
    is 0rIC, 99, q{Roman numeral 99 subtractive};
    is 0rMIM, 1999, q{Roman numeral 1999 subtractive};
  }, 'subtractive';

  is 0rMMXVI, 2016, q{Year of module release};

}, 'ASCII representations';

# There's also a Unicode range of Roman numerals, which lets us go into the
# hundreds of thousands.
#
# There's *also* a notation where you can put bars over a Roman numeral to
# multiply it by 1000, and stacking multiple bars means multiplying it by 1000
# each time.
#
# I may implement this if I'm feeling particularly masochistic.
#
subtest sub {
  is 0rⅠ, 1, q{Roman Unicode numeral 1};
  is 0rⅡ, 2, q{Roman Unicode numeral 2};
  is 0rⅢ, 3, q{Roman Unicode numeral 3};
  is 0rⅣ, 4, q{Roman Unicode numeral 4};
  is 0rⅤ, 5, q{Roman Unicode numeral 5};
  is 0rⅥ, 6, q{Roman Unicode numeral 6};
  is 0rⅦ, 7, q{Roman Unicode numeral 7};
  is 0rⅧ, 8, q{Roman Unicode numeral 8};
  is 0rⅨ, 9, q{Roman Unicode numeral 9};
  is 0rⅩ, 10, q{Roman Unicode numeral 10};
  is 0rⅪ, 11, q{Roman Unicode numeral 11};
  is 0rⅫ, 12, q{Roman Unicode numeral 12};
  is 0rⅬ, 50, q{Roman Unicode numeral 50};
  is 0rⅭ, 100, q{Roman Unicode numeral 100};
  is 0rⅮ, 500, q{Roman Unicode numeral 500};
  is 0rⅯ, 1_000, q{Roman Unicode numeral 1_000};
  is 0rↀ, 1_000, q{Roman Unicode numeral 1_000}; # Special uncial
  is 0rↁ, 5_000, q{Roman Unicode numeral 5_000};
  is 0rↂ, 10_000, q{Roman Unicode numeral 10_000};
  is 0rↇ, 50_000, q{Roman Unicode numeral 50_000};
  is 0rↈ, 100_000, q{Roman Unicode numeral 100_000};
}, 'Unicode range';

# Make sure that Roman numerals act like regular numbers, in that you can put
# them in variables and pass them to expressions.
#
is 0rI + 1, 2, q{Roman numeral 1 in expression};

my $v = 0rI;
is $v, 1, q{Roman numeral 1 in variable};

sub foo( Int $a, Int $b ) { $a + $b }

is foo( 0rIV, 0rVI ), 10, q{Roman numerals in expression};
