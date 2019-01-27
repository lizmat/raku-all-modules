use v6.c;
use NativeCall;
use Algorithm::LDA::Document;

unit class Algorithm::LDA::Formatter:ver<0.0.9>:auth<cpan:TITSUKI>;

method from-plain(@documents is raw, &tokenizer = { .words }) {
    my %word2type;
    my $destringed-documents = CArray[Algorithm::LDA::Document].allocate: +@documents;
    for ^@documents -> $doc-index {
        my Int @words;
        my Str @tokenized = @documents[$doc-index].flatmap(&tokenizer);
        for ^@tokenized -> $word-index {
            unless %word2type{@tokenized[$word-index]}:exists {
                %word2type{@tokenized[$word-index]} = %word2type.elems;
            }
            @words.push: %word2type{@tokenized[$word-index]};
        }
        $destringed-documents[$doc-index] = Algorithm::LDA::Document.new(:length(+@tokenized), :@words);
    }

    my @vocabs;
    for %word2type -> (:key($surface), :value($index)) {
        @vocabs[$index] = $surface;
    }
    ($destringed-documents, @vocabs.item);
}

method from-libsvm(@documents) {
    my $documents = CArray[Algorithm::LDA::Document].allocate: +@documents;

    my Int $idx = 0;
    for @documents {
        my ($doc_i, *@wfreqs) = .words;
        my @words;
        for @wfreqs -> $wfreq {
            my ($word, $freq) = $wfreq.split(":");
            @words.push($word.Int) for ^$freq;
        }
        $documents[$idx++] = Algorithm::LDA::Document.new(:length(+@words), :@words);
    }
    $documents;
}
