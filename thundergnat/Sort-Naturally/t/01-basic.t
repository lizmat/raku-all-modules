use v6;
use Test;
use Sort::Naturally;

plan 5;

my @test;
my $nsorted = '';

# does it deal with Nil in a sane fashion?
is(~Nil.sort( { .&naturally } ), $nsorted,
  "calling &naturally in a sort block on Nil is ok");
  
# does it deal with empty array in a sane fashion?

is(~@test.sort( { .&naturally } ), $nsorted,
  "calling &naturally in a sort block on an empty array is ok");

is(<5>.sort( { .&naturally } ), '5',
  "calling &naturally in a single item is ok");

# does it return the terms in the expected order?
@test = <2 210 21 30 3rd d1 d10 D2 D21 d3 aid Are any ANY 1 Any 11 100 14th>;
$nsorted = '1 2 3rd 11 14th 21 30 100 210 aid ANY Any any Are d1 D2 d3 d10 D21';

# randomize list for each test
# could conceivably fail under some locales

is(~@test.pick(*).sort( { .&naturally } ), $nsorted,
  "calling &naturally in a sort block yields expected order");

# does the compatibility routine return terms in the expected order?
my @p5test = <foo12z foo foo13a fooa Foolio Foo12a foolio foo12 foo12a 9x 14>;
my $p5nsorted = '9x 14 foo fooa Foolio foolio foo12 Foo12a foo12a foo12z foo13a';

# randomize list for the test
# could conceivably fail under some locales

is(~@p5test.pick(*).sort( { .&p5naturally } ),
  $p5nsorted, "calling &p5naturally in a sort block yields expected order");
  
done();
