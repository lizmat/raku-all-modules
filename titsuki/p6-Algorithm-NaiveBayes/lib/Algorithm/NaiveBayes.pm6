use v6;

use Algorithm::NaiveBayes::Classifiable;
use Algorithm::NaiveBayes::Classifier::Multinomial;
use Algorithm::NaiveBayes::Classifier::Bernoulli;
unit class Algorithm::NaiveBayes;

has Algorithm::NaiveBayes::Classifiable $!classifier;

enum Solver <Bernoulli Multinomial>;

submethod BUILD(Solver :$solver = Multinomial) {
    given $solver {
	when Bernoulli {
	    $!classifier = Algorithm::NaiveBayes::Classifier::Bernoulli.new;
	}
	when Multinomial {
	    $!classifier = Algorithm::NaiveBayes::Classifier::Multinomial.new;
	}
    }
}

method train() {
    $!classifier.train();
}

multi method predict(%v) {
    $!classifier.predict(%v);
}

multi method predict(Str $text) {
    $!classifier.predict($text);
}

multi method add-document(%attributes, Str $label) {
    $!classifier.add-document(%attributes, $label);
}

multi method add-document(Str @words, Str $label) {
    $!classifier.add-document(@words, $label);
}

multi method add-document(Str $text, Str $label) {
    $!classifier.add-document($text, $label);
}

method word-given-class(Str $word, Str $class) {
    $!classifier.word-given-class($word, $class);
}

=begin pod

=head1 NAME

Algorithm::NaiveBayes - A Perl 6 Naive Bayes classifier implementation

=head1 SYNOPSIS

=head2 EXAMPLE1

  use Algorithm::NaiveBayes;

  my $nb = Algorithm::NaiveBayes.new(solver => Algorithm::NaiveBayes::Multinomial);
  $nb.add-document("Chinese Beijing Chinese", "China");
  $nb.add-document("Chinese Chinese Shanghai", "China");
  $nb.add-document("Chinese Macao", "China");
  $nb.add-document("Tokyo Japan Chinese", "Japan");
  $nb.train();
  my @result = $nb.predict("Chinese Chinese Chinese Tokyo Japan");
  @result.say; # [China => -8.10769031284391 Japan => -8.90668134500126]

=head2 EXAMPLE2

  use Algorithm::NaiveBayes;
  
  my $nb = Algorithm::NaiveBayes.new(solver => Algorithm::NaiveBayes::Bernoulli);
  $nb.add-document("Chinese Beijing Chinese", "China");
  $nb.add-document("Chinese Chinese Shanghai", "China");
  $nb.add-document("Chinese Macao", "China");
  $nb.add-document("Tokyo Japan Chinese", "Japan");
  $nb.train();
  my @result = $nb.predict("Chinese Chinese Chinese Tokyo Japan");
  @result.say; # [Japan => -3.81908500976888 China => -5.26217831993216]

=head1 DESCRIPTION

Algorithm::NaiveBayes is a Perl 6 Naive Bayes classifier implementation.

=head2 CONSTRUCTOR

       my $nb = Algorithm::NaiveBayes.new(); # default solver is Multinomial
       my $nb = Algorithm::NaiveBayes.new(%options);

=head3 OPTIONS

=item C<<solver => Algorithm::NaiveBayes::Multinomial|Algorithm::NaiveBayes::Bernoulli>> 

=head2 METHODS

=head3 add-document

       multi method add-document(%attributes, Str $label)
       multi method add-document(Str @words, Str $label)
       multi method add-document(Str $text, Str $label)
       
Adds a document used for training. C<<%attributes>> is the key-value pair, where key is the word and value is the frequency of occurrence of the word in the document. C<<@words>> is the bag-of-words. The bag-of-words is represented as a multiset of words occurrence in the document. C<<$text>> is the plain text of the document. It will be splitted by whitespaces and processed as the bag-of-words internally.

=head3 train

Starts the training.

=head3 predict

       multi method predict(Str $text)
       multi method predict(%attributes)

Returns the log conditional a-posterior probabilities for each class. The resulting list is sorted by descending order of probability. You must call the train method before the prediction.

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

This algorithm is from Manning, Christopher D., Prabhakar Raghavan, and Hinrich Schutze. Introduction to information retrieval. Vol. 1. No. 1. Cambridge: Cambridge university press, 2008.

=end pod
