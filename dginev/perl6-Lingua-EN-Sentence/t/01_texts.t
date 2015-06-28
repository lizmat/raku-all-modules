use v6;
use Test;
use Lingua::EN::Sentence;

my @tests = dir 't/data', test => /'.txt' $$/;
plan @tests.elems;

for @tests.sort -> $test {
 $test ~~ /(.+) '.txt' $$/;
 my $name = $0;
 my $text = slurp $test;
 my @sentences = slurp("$name.sents").split("\n-----\n");
 my @new_sentences = $text.sentences;
 my Str $diff="\n";
 my Str $expected_diff="\n";
 for @sentences Z @new_sentences -> ($s1, $s2) {
     if ($s1 ne $s2) {
       $diff ~= "Expected: $s1\nGot: $s2\n"; 
     }
 }
 is($diff,$expected_diff,$name);
}
