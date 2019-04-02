[![Build Status](https://travis-ci.org/titsuki/p6-Algorithm-HierarchicalPAM.svg?branch=master)](https://travis-ci.org/titsuki/p6-Algorithm-HierarchicalPAM)

NAME
====

Algorithm::HierarchicalPAM - A Perl 6 Hierarchical PAM (model 2) implementation.

SYNOPSIS
========

EXAMPLE 1
---------

    use Algorithm::HierarchicalPAM;
    use Algorithm::HierarchicalPAM::Formatter;
    use Algorithm::HierarchicalPAM::HierarchicalPAMModel;

    my @documents = (
        "a b c",
        "d e f",
    );
    my ($documents, $vocabs) = Algorithm::HierarchicalPAM::Formatter.from-plain(@documents);
    my Algorithm::HierarchicalPAM $hpam .= new(:$documents, :$vocabs);
    my Algorithm::HierarchicalPAMModel $model = $hpam.fit(:num-super-topics(3), :num-sub-topics(5), :num-iterations(500));

    $model.topic-word-matrix.say; # show topic-word matrix
    $model.document-topic-matrix; # show document-topic matrix
    $model.log-likelihood.say; # show likelihood 
    $model.nbest-words-per-topic.say # show nbest words per topic

EXAMPLE 2
---------

    use Algorithm::HierarchicalPAM;
    use Algorithm::HierarchicalPAM::Formatter;
    use Algorithm::HierarchicalPAM::HierarchicalPAMModel;

    # Note: You can get AP corpus as follows:
    # $ wget "https://github.com/Blei-Lab/lda-c/blob/master/example/ap.tgz?raw=true" -O ap.tgz
    # $ tar xvzf ap.tgz

    my @vocabs = "./ap/vocab.txt".IO.lines;
    my @documents = "./ap/ap.dat".IO.lines;
    my $documents  = Algorithm::HierarchicalPAM::Formatter.from-libsvm(@documents);

    my Algorithm::HierarchicalPAM $hpam .= new(:$documents, :@vocabs);
    my Algorithm::HierarchicalPAM::HierarchicalPAMModel $model = $hpam.fit(:num-super-topics(10), :num-sub-topics(20), :num-iterations(500));

    $model.topic-word-matrix.say; # show topic-word matrix
    $model.document-topic-matrix; # show document-topic matrix
    $model.log-likelihood.say; # show likelihood 
    $model.nbest-words-per-topic.say # show nbest words per topic

DESCRIPTION
===========

Algorithm::HierarchicalPAM - A Perl 6 Hierarchical PAM (model 2) implementation.

CONSTRUCTOR
-----------

### new

Defined as:

    submethod BUILD(:$!documents!, :$!vocabs! is raw) { }

Constructs a new Algorithm::HierarchicalPAM instance.

METHODS
-------

### fit

Defined as:

    method fit(Int :$num-iterations = 500, Int :$num-super-topics!, Int :$num-sub-topics!, Num :$alpha = 0.1e0, Num :$beta = 0.1e0, Int :$seed --> Algorithm::HierarchicalPAM::HierarchicalPAMModel)

Returns an Algorithm::HierarchicalPAM::HierarchicalPAMModel instance.

  * `:$num-iterations` is the number of iterations for gibbs sampler

  * `:$num-super-topics!` is the number of super topics

  * `:$num-sub-topics!` is the number of sub topics

  * `alpha` is the prior for theta distribution (i.e., document-topic distribution)

  * `beta` is the prior for phi distribution (i.e., topic-word distribution)

  * `seed` is the seed for srand

AUTHOR
======

titsuki <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2019 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

The algorithm is from:

  * Mimno, David, Wei Li, and Andrew McCallum. "Mixtures of hierarchical topics with pachinko allocation." Proceedings of the 24th international conference on Machine learning. ACM, 2007.

  * Minka, Thomas. "Estimating a Dirichlet distribution." (2000): 4.

