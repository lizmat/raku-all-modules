[![Build Status](https://travis-ci.org/titsuki/p6-Algorithm-NaiveBayes.svg?branch=master)](https://travis-ci.org/titsuki/p6-Algorithm-NaiveBayes)

NAME
====

Algorithm::NaiveBayes - A Perl 6 Naive Bayes classifier implementation

SYNOPSIS
========

EXAMPLE1
--------

    use Algorithm::NaiveBayes;

    my $nb = Algorithm::NaiveBayes.new(solver => Algorithm::NaiveBayes::Multinomial);
    $nb.add-document("Chinese Beijing Chinese", "China");
    $nb.add-document("Chinese Chinese Shanghai", "China");
    $nb.add-document("Chinese Macao", "China");
    $nb.add-document("Tokyo Japan Chinese", "Japan");
    $nb.train();
    my @result = $nb.predict("Chinese Chinese Chinese Tokyo Japan");
    @result.say; # [China => -8.10769031284391 Japan => -8.90668134500126]

EXAMPLE2
--------

    use Algorithm::NaiveBayes;

    my $nb = Algorithm::NaiveBayes.new(solver => Algorithm::NaiveBayes::Bernoulli);
    $nb.add-document("Chinese Beijing Chinese", "China");
    $nb.add-document("Chinese Chinese Shanghai", "China");
    $nb.add-document("Chinese Macao", "China");
    $nb.add-document("Tokyo Japan Chinese", "Japan");
    $nb.train();
    my @result = $nb.predict("Chinese Chinese Chinese Tokyo Japan");
    @result.say; # [Japan => -3.81908500976888 China => -5.26217831993216]

DESCRIPTION
===========

Algorithm::NaiveBayes is a Perl 6 Naive Bayes classifier implementation.

CONSTRUCTOR
-----------

    my $nb = Algorithm::NaiveBayes.new(); # default solver is Multinomial
    my $nb = Algorithm::NaiveBayes.new(%options);

### OPTIONS

  * `solver => Algorithm::NaiveBayes::Multinomial|Algorithm::NaiveBayes::Bernoulli` 

METHODS
-------

### add-document

    multi method add-document(%attributes, Str $label)
    multi method add-document(Str @words, Str $label)
    multi method add-document(Str $text, Str $label)

Adds a document used for training. `%attributes` is the key-value pair, where key is the word and value is the frequency of occurrence of the word in the document. `@words` is the bag-of-words. The bag-of-words is represented as a multiset of words occurrence in the document. `$text` is the plain text of the document. It will be splitted by whitespaces and processed as the bag-of-words internally.

### train

Starts the training.

### predict

    multi method predict(Str $text)
    multi method predict(%attributes)

Returns the log conditional a-posterior probabilities for each class. The resulting list is sorted by descending order of probability. You must call the train method before the prediction.

AUTHOR
======

titsuki <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

This algorithm is from Manning, Christopher D., Prabhakar Raghavan, and Hinrich Schutze. Introduction to information retrieval. Vol. 1. No. 1. Cambridge: Cambridge university press, 2008.
