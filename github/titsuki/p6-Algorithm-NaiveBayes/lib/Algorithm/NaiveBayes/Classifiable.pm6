use v6;

unit role Algorithm::NaiveBayes::Classifiable;

method train() { ... }
multi method predict(%hash) { ... }
multi method predict(Str $text) { ... }
multi method add-document(%attributes, Str) { ... }
multi method add-document(Str @words, Str) { ... }
multi method add-document(Str, Str) { ... }
method word-given-class(Str, Str) { ... }

method hash2array-pair(%hash) {
    my @res;
    for %hash.sort({ $^b.value cmp $^a.value }) -> (:$key, :$value) {
	@res.push(Pair.new($key, $value));
    }
    return @res;
}
