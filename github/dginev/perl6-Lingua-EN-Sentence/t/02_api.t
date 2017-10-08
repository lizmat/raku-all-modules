use v6;
use Test;
use Lingua::EN::Sentence;

plan 2;

my $t = "A sample test, or te. 2, for short? Ok.";
is($t.sentences.elems, 3, 'unregistered t');

add_acronyms('te'); # Let's introduce te.
is(get_sentences($t).elems,2, 'registered t'); # and exercise get_sentences