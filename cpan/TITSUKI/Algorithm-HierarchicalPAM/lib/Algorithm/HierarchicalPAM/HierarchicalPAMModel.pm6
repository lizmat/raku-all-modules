use v6.c;
use NativeCall;
use Algorithm::HierarchicalPAM::Document;
use Algorithm::HierarchicalPAM::Theta;
use Algorithm::HierarchicalPAM::Phi;

unit class Algorithm::HierarchicalPAM::HierarchicalPAMModel:ver<0.0.1>:auth<cpan:TITSUKI>;

my constant $library = %?RESOURCES<libraries/hpam>.Str;

my sub hpam_log_likelihood(Algorithm::HierarchicalPAM::Phi, CArray[Algorithm::HierarchicalPAM::Theta] --> num64) is native($library) { * }

has CArray[Algorithm::HierarchicalPAM::Theta] $!theta;
has Algorithm::HierarchicalPAM::Phi $!phi;
has $!documents; # TODO: Type checking doesn't work due to the "... but got CArray[XXX].new" error
has @!vocabs;

submethod BUILD(:$!theta! is raw, :$!phi! is raw, :$!documents! is raw, :@!vocabs! is raw) { }

method log-likelihood(--> Num) {
    hpam_log_likelihood($!phi, $!theta);
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
    my $theta-super := $!theta.list[0];
    my $theta-sub := $!theta.list[1];
    my $total-topics = $theta-sub.num-super-topics + $theta-sub.num-super-topics * $theta-sub.num-sub-topics;
    my @matrix[+$!documents.list;$total-topics];
    for ^$!documents.list -> $doc-index {
        my @weight;
        for ^$total-topics -> $p {
            if $p < $theta-sub.num-super-topics {
                @matrix[$doc-index;$p] = $theta-super.weight(0, $p, $doc-index);
            }
            elsif $p >= $theta-sub.num-super-topics {
                my $super = ($p - $theta-sub.num-super-topics) % $theta-sub.num-super-topics;
                my $sub = ($p - $theta-sub.num-super-topics) div $theta-sub.num-super-topics;
                @matrix[$doc-index;$p] = $theta-super.weight(0, $super, $doc-index) + $theta-sub.weight($super, $sub, $doc-index);
            }
        }
    }
    @matrix;
}

method vocabulary(--> List) {
    @!vocabs
}

