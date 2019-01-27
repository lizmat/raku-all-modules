use v6.c;
use NativeCall;
use Algorithm::LDA::Document;
use Algorithm::LDA::Theta;
use Algorithm::LDA::Phi;

unit class Algorithm::LDA::LDAModel:ver<0.0.9>:auth<cpan:TITSUKI>;

my constant $library = %?RESOURCES<libraries/lda>.Str;

my sub lda_log_likelihood(Algorithm::LDA::Phi, CArray[Algorithm::LDA::Theta] --> num64) is native($library) { * }
my sub lda_heldout_log_likelihood(CArray[Algorithm::LDA::Document], Algorithm::LDA::Phi, int32, int32 --> num64) is native($library) { * }

has CArray[Algorithm::LDA::Theta] $!theta;
has Algorithm::LDA::Phi $!phi;
has $!documents; # TODO: Type checking doesn't work due to the "... but got CArray[XXX].new" error
has @!vocabs;

submethod BUILD(:$!theta! is raw, :$!phi! is raw, :$!documents! is raw, :@!vocabs! is raw) { }

# Note: heldout-log-likelihood is highly experimental
# method heldout-log-likelihood($documents --> Num) {
#     lda_heldout_log_likelihood($documents, $!phi, $!phi.num-topics, +$!documents.list);
# }

method log-likelihood(--> Num) {
    lda_log_likelihood($!phi, $!theta);
}

method nbest-words-per-topic(Int $n = 10 --> List) {
    my Int $n-max = ($n > +@!vocabs ?? +@!vocabs !! $n);
    my @matrix[$!phi.num-topics;$n-max];
    for ^$!phi.num-topics -> $p {
        my @words;
        for ^@!vocabs -> $word-type {
            my $weight = $!phi.weight($p, $word-type);
            @words.push: Pair.new(@!vocabs[$word-type], $weight);
        }
        @matrix[$p;.key] = .value for @words.sort({ $^b.value <=> $^a.value }).head($n-max).pairs;
    }
    @matrix;
}

method topic-word-matrix(--> List) {
    my @matrix[$!phi.num-topics;+@!vocabs];
    for ^$!phi.num-topics -> $p {
        my Int $index = 0;
        for ^@!vocabs -> $word-type {
            my $weight = $!phi.weight($p, $word-type);
            @matrix[$p;$index] = $weight;
            $index++;
        }
    }
    @matrix;
}

method document-topic-matrix(--> List) {
    my $theta := $!theta.list[0];
    my @matrix[+$!documents.list;$theta.num-sub-topics];
    for ^$!documents.list -> $doc-index {
        my @weight;
        for ^$theta.num-sub-topics -> $p {
            @matrix[$doc-index;$p] = $theta.weight(0, $p, $doc-index);
        }
    }
    @matrix;
}

method vocabulary(--> List) {
    @!vocabs
}
