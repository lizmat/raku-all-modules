use v6;
use lib 'lib';
use Text::Names;

#this code is under MIT license
say "Please look at the below lines and confirm that they are true";
say "$( get-male() ) is a male first name";
say "$( get-female() ) is a female first name";
say "$( get-full() ) is a full name";

say "# now starting performance testing";
my constant NUM_OF_TRIALS = 100;

{

my $*buffer-size = 1; 
my $first-time = now; 
get-full() for ^NUM_OF_TRIALS;
say "slow mode took $(now - $first-time) to generate $(NUM_OF_TRIALS) names";
}

{

my $*buffer-size = NUM_OF_TRIALS; 
my $first-time = now; 
get-full() for ^NUM_OF_TRIALS;
say "With a buffer of size $(NUM_OF_TRIALS), $(now - $first-time) to generate $(NUM_OF_TRIALS) names";
}
