use v6.c;
use NativeCall;
use Algorithm::HierarchicalPAM::Document;
use Algorithm::HierarchicalPAM::Theta;
use Algorithm::HierarchicalPAM::Phi;
use Algorithm::HierarchicalPAM::HierarchicalPAMModel;
unit class Algorithm::HierarchicalPAM:ver<0.0.1>:auth<cpan:TITSUKI>;

my constant $library = %?RESOURCES<libraries/hpam>.Str;

my sub hpam_fit(CArray[Algorithm::HierarchicalPAM::Document], Algorithm::HierarchicalPAM::Phi, CArray[Algorithm::HierarchicalPAM::Theta], int32, int32, int32, int32) is native($library) { * }
my sub hpam_set_srand(int32) is native($library) { * }

has CArray $!documents; # TODO: Type checking doesn't work due to the "... but got CArray[XXX].new" error
has List $!vocabs;

submethod BUILD(CArray :$!documents!, :$!vocabs! is raw) { }

method fit(Int :$num-iterations = 500, Int :$num-super-topics!, Int :$num-sub-topics!, Num :$alpha = 0.1e0, Num :$beta = 0.1e0, Int :$seed --> Algorithm::HierarchicalPAM::HierarchicalPAMModel) {
    if $seed.defined {
        hpam_set_srand($seed);
    }
    my $phi = Algorithm::HierarchicalPAM::Phi.new(:num-sub-topic($num-super-topics + $num-super-topics * $num-sub-topics), :num-word-type(+@$!vocabs), :$beta);
    my $theta = CArray[Algorithm::HierarchicalPAM::Theta].allocate: 2;
    $theta[0] = Algorithm::HierarchicalPAM::Theta.new(:num-super-topic(1),
                                                      :num-sub-topic($num-super-topics),
                                                      :num-doc($!documents.elems),
                                                      :$alpha);
    $theta[1] = Algorithm::HierarchicalPAM::Theta.new(:num-super-topic($num-super-topics),
                                                      :num-sub-topic($num-sub-topics),
                                                      :num-doc($!documents.elems),
                                                      :$alpha);
    hpam_fit($!documents, $phi, $theta, $num-super-topics, $num-sub-topics, $!documents.elems, $num-iterations);
    Algorithm::HierarchicalPAM::HierarchicalPAMModel.new(:$theta, :$phi, :$!documents, :$!vocabs);
}

=begin pod

=head1 NAME

Algorithm::HierarchicalPAM - A Perl 6 Hierarchical PAM (model 2) implementation.

=head1 SYNOPSIS

=head2 EXAMPLE 1

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

=head2 EXAMPLE 2

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

=head1 DESCRIPTION

Algorithm::HierarchicalPAM - A Perl 6 Hierarchical PAM (model 2) implementation.

=head2 CONSTRUCTOR

=head3 new

Defined as:

      submethod BUILD(:$!documents!, :$!vocabs! is raw) { }

Constructs a new Algorithm::HierarchicalPAM instance.

=head2 METHODS

=head3 fit

Defined as:

      method fit(Int :$num-iterations = 500, Int :$num-super-topics!, Int :$num-sub-topics!, Num :$alpha = 0.1e0, Num :$beta = 0.1e0, Int :$seed --> Algorithm::HierarchicalPAM::HierarchicalPAMModel)

Returns an Algorithm::HierarchicalPAM::HierarchicalPAMModel instance.

=item C<:$num-iterations> is the number of iterations for gibbs sampler

=item C<:$num-super-topics!> is the number of super topics

=item C<:$num-sub-topics!> is the number of sub topics

=item C<alpha> is the prior for theta distribution (i.e., document-topic distribution)

=item C<beta> is the prior for phi distribution (i.e., topic-word distribution)

=item C<seed> is the seed for srand

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2019 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

The algorithm is from:

=item Mimno, David, Wei Li, and Andrew McCallum. "Mixtures of hierarchical topics with pachinko allocation." Proceedings of the 24th international conference on Machine learning. ACM, 2007.

=item Minka, Thomas. "Estimating a Dirichlet distribution." (2000): 4.

=end pod
