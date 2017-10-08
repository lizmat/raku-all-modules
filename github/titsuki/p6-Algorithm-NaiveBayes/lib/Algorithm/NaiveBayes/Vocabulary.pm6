use v6;
unit class Algorithm::NaiveBayes::Vocabulary;

has %.attributes;

multi submethod BUILD(Str :$text!) {
    for $text.split(" ") -> $word {
	%!attributes{$word} += 1;
    }
}

multi submethod BUILD(Str :@words!) {
    for @words -> $word {
	%!attributes{$word} += 1;
    }
}

multi submethod BUILD(:%!attributes!) { }

multi method add(Str $word, Int $freq) {
    %!attributes{$word} += $freq;
}

multi method add(@words) {
    for @words -> $word {
	%!attributes{$word} += 1;
    }
}

method kv() {
    %!attributes.kv;
}

method has-word(Str $word) {
    %!attributes{$word}:exists;
}
