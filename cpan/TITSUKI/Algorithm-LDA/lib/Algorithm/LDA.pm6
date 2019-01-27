use v6.c;
use NativeCall;
use Algorithm::LDA::Document;
use Algorithm::LDA::Theta;
use Algorithm::LDA::Phi;
use Algorithm::LDA::LDAModel;
unit class Algorithm::LDA:ver<0.0.9>:auth<cpan:TITSUKI>;

my constant $library = %?RESOURCES<libraries/lda>.Str;

my sub lda_fit(CArray[Algorithm::LDA::Document], Algorithm::LDA::Phi, CArray[Algorithm::LDA::Theta], int32, int32, int32) is native($library) { * }
my sub lda_set_srand(int32) is native($library) { * }

has $!documents; # TODO: Type checking doesn't work due to the "... but got CArray[XXX].new" error
has List $!vocabs;

submethod BUILD(:$!documents!, :$!vocabs! is raw) { }

method fit(Int :$num-iterations = 500, Int :$num-topics!, Num :$alpha = 0.1e0, Num :$beta = 0.1e0, Int :$seed --> Algorithm::LDA::LDAModel) {
    if $seed.defined {
        lda_set_srand($seed);
    }
    my $phi = Algorithm::LDA::Phi.new(:num-sub-topic($num-topics), :num-word-type(+@$!vocabs), :$beta);
    my $theta = CArray[Algorithm::LDA::Theta].allocate: 1;
    $theta[0] = Algorithm::LDA::Theta.new(:num-super-topic(1),
                                          :num-sub-topic($num-topics),
                                          :num-doc($!documents.elems),
                                          :$alpha);
    lda_fit($!documents, $phi, $theta, $num-topics, $!documents.elems, $num-iterations);
    Algorithm::LDA::LDAModel.new(:$theta, :$phi, :$!documents, :$!vocabs);
}

=begin pod

=head1 NAME

Algorithm::LDA - A Perl 6 Latent Dirichlet Allocation implementation.

=head1 SYNOPSIS

=head2 EXAMPLE 1

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

=head2 EXAMPLE 2

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

=head1 DESCRIPTION

Algorithm::LDA is a Perl 6 Latent Dirichlet Allocation implementation.

=head2 CONSTRUCTOR

=head3 new

Defined as:

      submethod BUILD(:$!documents!, :$!vocabs! is raw) { }

Constructs a new Algorithm::LDA instance.

=head2 METHODS

=head3 fit

Defined as:

      method fit(Int :$num-iterations = 500, Int :$num-topics!, Num :$alpha = 0.1e0, Num :$beta = 0.1e0, Int :$seed --> Algorithm::LDA::LDAModel)

Returns an Algorithm::LDA::LDAModel instance.

=item C<:$num-ierations> is the number of iterations for gibbs sampler

=item C<:$num-topics!> is the number of topics

=item C<alpha> is the prior for theta distribution (i.e., document-topic distribution)

=item C<beta> is the prior for phi distribution (i.e., topic-word distribution)

=item C<seed> is the seed for srand

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

The algorithm is from:

=item Blei, David M., Andrew Y. Ng, and Michael I. Jordan. "Latent dirichlet allocation." Journal of machine Learning research 3.Jan (2003): 993-1022.

=item Li, Wei, and Andrew McCallum. "Pachinko allocation: DAG-structured mixture models of topic correlations." Proceedings of the 23rd international conference on Machine learning. ACM, 2006.

=item Wallach, Hanna M., et al. "Evaluation methods for topic models." Proceedings of the 26th annual international conference on machine learning. ACM, 2009.

=item Minka, Thomas. "Estimating a Dirichlet distribution." (2000): 4.

=end pod
