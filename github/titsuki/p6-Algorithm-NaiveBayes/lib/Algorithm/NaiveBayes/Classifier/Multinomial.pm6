use v6;
use Algorithm::NaiveBayes::Document;
use Algorithm::NaiveBayes::Classifiable;
use Algorithm::NaiveBayes::ModelUpdatable;

unit class Algorithm::NaiveBayes::Classifier::Multinomial;
also does Algorithm::NaiveBayes::Classifiable;
also does Algorithm::NaiveBayes::ModelUpdatable;

has Algorithm::NaiveBayes::Document @!docs;
has %.word-class-freq;
has %.word-freq;
has %.class-freq;

submethod BUILD() {}

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
	for $doc.vocabulary.kv -> $word, $freq {
	    $prob += $freq * log(self.word-given-class($word, $class));
	}
	$prob += log(%!class-freq{$class} / [+] %!class-freq.values);
	%res{$class} = $prob;
    }
    return self.hash2array-pair(%res);
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
	%!word-class-freq{$word}{$doc.label} += $freq;
	%!word-freq{$word} += $freq;
    }
}

method word-given-class($word, $class) {
    my $a = self!wc-freq($word, $class) + 1;
    my $b = 0;
    for %!word-freq.keys -> $word {
	$b += self!wc-freq($word, $class) + 1;
    }
    return $a / $b;
}

method !wc-freq($word, $class) {
    %!word-class-freq{$word}{$class}:exists ?? %!word-class-freq{$word}{$class} !! 0;
}
