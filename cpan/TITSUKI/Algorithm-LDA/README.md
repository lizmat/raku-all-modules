[![Build Status](https://travis-ci.org/titsuki/p6-Algorithm-LDA.svg?branch=master)](https://travis-ci.org/titsuki/p6-Algorithm-LDA)

NAME
====

Algorithm::LDA - A Perl 6 Latent Dirichlet Allocation implementation.

SYNOPSIS
========

EXAMPLE 1
---------

    use Algorithm::LDA;
    use Algorithm::LDA::Formatter;
    use Algorithm::LDA::LDAModel;

    my @documents = (
        "a b c",
        "d e f",
    );
    my ($documents, $vocabs) = Algorithm::LDA::Formatter.from-plain(@documents);
    my Algorithm::LDA $lda .= new(:$documents, :$vocabs);
    my Algorithm::LDA::LDAModel $model = $lda.fit(:num-topics(3), :num-iterations(500));

    $model.topic-word-matrix.say; # show topic-word matrix
    $model.document-topic-matrix; # show document-topic matrix
    $model.log-likelihood.say; # show likelihood 
    $model.nbest-words-per-topic.say # show nbest words per topic

EXAMPLE 2
---------

    use Algorithm::LDA;
    use Algorithm::LDA::Formatter;
    use Algorithm::LDA::LDAModel;

    # Note: You can get AP corpus as follows:
    # $ wget "https://github.com/Blei-Lab/lda-c/blob/master/example/ap.tgz?raw=true" -O ap.tgz
    # $ tar xvzf ap.tgz

    my @vocabs = "./ap/vocab.txt".IO.lines;
    my @documents = "./ap/ap.dat".IO.lines;
    my $documents  = Algorithm::LDA::Formatter.from-libsvm(@documents);

    my Algorithm::LDA $lda .= new(:$documents, :@vocabs);
    my Algorithm::LDA::LDAModel $model = $lda.fit(:num-topics(20), :num-iterations(500));

    $model.topic-word-matrix.say; # show topic-word matrix
    $model.document-topic-matrix; # show document-topic matrix
    $model.log-likelihood.say; # show likelihood 
    $model.nbest-words-per-topic.say # show nbest words per topic

DESCRIPTION
===========

Algorithm::LDA is a Perl 6 Latent Dirichlet Allocation implementation.

CONSTRUCTOR
-----------

### new

Defined as:

    submethod BUILD(:$!documents!, :$!vocabs! is raw) { }

Constructs a new Algorithm::LDA instance.

METHODS
-------

### fit

Defined as:

    method fit(Int :$num-iterations = 500, Int :$num-topics!, Num :$alpha = 0.1e0, Num :$beta = 0.1e0, Int :$seed --> Algorithm::LDA::LDAModel)

Returns an Algorithm::LDA::LDAModel instance.

  * `:$num-ierations` is the number of iterations for gibbs sampler

  * `:$num-topics!` is the number of topics

  * `alpha` is the prior for theta distribution (i.e., document-topic distribution)

  * `beta` is the prior for phi distribution (i.e., topic-word distribution)

  * `seed` is the seed for srand

AUTHOR
======

titsuki <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

The algorithm is from:

  * Blei, David M., Andrew Y. Ng, and Michael I. Jordan. "Latent dirichlet allocation." Journal of machine Learning research 3.Jan (2003): 993-1022.

  * Li, Wei, and Andrew McCallum. "Pachinko allocation: DAG-structured mixture models of topic correlations." Proceedings of the 23rd international conference on Machine learning. ACM, 2006.

  * Wallach, Hanna M., et al. "Evaluation methods for topic models." Proceedings of the 26th annual international conference on machine learning. ACM, 2009.

  * Minka, Thomas. "Estimating a Dirichlet distribution." (2000): 4.

