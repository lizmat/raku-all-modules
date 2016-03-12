use lib 'lib';
use Test;
use Lingua::EN::Stem::Porter;

plan 30428;

my IO::Path $data-path = 't/data'.IO;

# The following wordlists are originally from
# http://snowball.tartarus.org/algorithms/porter/stemmer.html but have been modified slightly.
my @wordlist-input =     $data-path.child("wordlist-input.txt").open.lines;
my @wordlist-expected =  $data-path.child("wordlist-expected.txt").open.lines;

my ($stem, $word, $expected-stem);
for ^@wordlist-input -> $i {
    $word = @wordlist-input[$i];
    $expected-stem = @wordlist-expected[$i];
    $stem = porter($word);
    is $stem, $expected-stem, "The stem of $word, $stem, should be $expected-stem";
}

done-testing;
