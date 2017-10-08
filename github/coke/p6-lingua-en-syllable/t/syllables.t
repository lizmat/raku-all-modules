use v6;
use Test;

use Lingua::EN::Syllable;

# all words specfically noted in the original p5 variant test/source,
# plus a few others.

my %syl = (
    "absolutely" => 4,
    "agreeable" => 4,
    "aquaculture" => 4,
    "alien" => 3,
    "battle" => 2,
    "belgium" => 2,
    "bilingual" => 3,
    "bottle" => 2,
    "coadjutor" => 4,
    "coagulable" => 5,
    "coagulate" => 4,
    "coalesce" => 3,
    "coalescent" => 4,
    "coalition" => 4,
    "coaxial" => 4,
    "couldn't" => 2,
    "ebbullient" => 3,
    "ely" => 2,
    "hoopty" => 2,
    "lien" => 1,
    "middle" => 2,
    "salient" => 3,
    "twiddle" => 2,
);

plan(+%syl);

for %syl.kv -> $word, $count {
    is(syllable($word), $count, "$word has $count syllables");
}

