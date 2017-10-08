use v6;
use Algorithm::NaiveBayes::Vocabulary;

unit class Algorithm::NaiveBayes::Document;

has Algorithm::NaiveBayes::Vocabulary $.vocabulary;
has Str $.label;

multi submethod BUILD(:%attributes!, :$!label = Str) {
    $!vocabulary = Algorithm::NaiveBayes::Vocabulary.new(:%attributes);
}

multi submethod BUILD(Str :$text!, :$!label = Str) {
    $!vocabulary = Algorithm::NaiveBayes::Vocabulary.new(:$text);
}

multi submethod BUILD(Str :@words!, :$!label = Str) {
    $!vocabulary = Algorithm::NaiveBayes::Vocabulary.new(:@words);
}

method has-word(Str $word) {
    $!vocabulary.has-word($word);
}

method update-model($visitor) {
    $visitor.update-model(self);
}
