use v6;
use Algorithm::NaiveBayes::Document;
use Algorithm::NaiveBayes::Classifiable;
use Algorithm::NaiveBayes::ModelUpdatable;

unit class Algorithm::NaiveBayes::Classifier::Bernoulli;
also does Algorithm::NaiveBayes::Classifiable;
also does Algorithm::NaiveBayes::ModelUpdatable;

has Algorithm::NaiveBayes::Document @!docs;
has %.word-class-contains;
has %.class-freq;
has %.word-contains;

multi method add-document(%attributes, Str $label) {
    @!docs.push(Algorithm::NaiveBayes::Document.new(:%attributes, :$label));
}

multi method add-document(Str @words, Str $label) {
    @!docs.push(Algorithm::NaiveBayes::Document.new(:@words, :$label));
}

multi method add-document(Str $text, Str $label) {
    @!docs.push(Algorithm::NaiveBayes::Document.new(:$text, :$label));
}

method train() {
    for @!docs -> $doc {
	self.update-model($doc);
    }
}

multi method predict(%hdoc) {
    my $doc = Algorithm::NaiveBayes::Document.new(:attributes(%hdoc));
    my %res;
    for %!class-freq.keys -> $class {
	my $prob = 0;
	for %!word-contains.keys -> $word {
	    if $doc.has-word($word) {
		$prob += log(self.word-given-class($word, $class));
	    } else {
		$prob += log(1 - self.word-given-class($word, $class));
	    }
	}
	$prob += log(%!class-freq{$class} / [+] %!class-freq.values);
	%res{$class} = $prob;
    }
    self.hash2array-pair(%res);
}

multi method predict(Str $text) {
    my @words = $text.split(" ");
    my %v;
    for @words -> $word {
	%v{$word}++;
    }
    self.predict(%v);
}

method update-model($doc) {
    %!class-freq{$doc.label} += 1;
    for $doc.vocabulary.kv -> $word, $freq {
	%!word-class-contains{$word}{$doc.label}++;
	%!word-contains{$word} = True;
    }
}

method word-given-class($word, $class) {
    my $a = self!count-docs-containing-word($word, $class) + 1;
    my $b = %!class-freq{$class} + 2;
    return $a / $b;
}

method !count-docs-containing-word($word, $class) {
    %!word-class-contains{$word}{$class}:exists ?? %!word-class-contains{$word}{$class} !! 0;
}
