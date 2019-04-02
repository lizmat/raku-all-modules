use v6.c;
use Test;
use Algorithm::HierarchicalPAM;
use Algorithm::HierarchicalPAM::HierarchicalPAMModel;
use Algorithm::HierarchicalPAM::Document;
use Algorithm::HierarchicalPAM::Formatter;

subtest {
    my @documents = (
        "a b c",
        "d e f",
    );
    my ($documents, $vocabs) = Algorithm::HierarchicalPAM::Formatter.from-plain(@documents);
    is-deeply $vocabs, ["a", "b", "c", "d", "e", "f"];
    my Algorithm::HierarchicalPAM $hpam .= new(:$documents, :$vocabs);
    my Algorithm::HierarchicalPAM::HierarchicalPAMModel $model = $hpam.fit(:num-super-topics(3), :num-sub-topics(5), :num-iterations(1000));
    lives-ok { $model.topic-word-matrix }
    lives-ok { $model.document-topic-matrix }
    lives-ok { $model.log-likelihood }
    lives-ok { $model.nbest-words-per-topic }
}, "Check if it could process a very short document. (just a smoke test)";

subtest {
    my @documents = (
        "a b c d",
        "e f g h",
    );
    my ($documents, $vocabs) = Algorithm::HierarchicalPAM::Formatter.from-plain(@documents);
    my Algorithm::HierarchicalPAM $lda .= new(:$documents, :$vocabs);
    my Algorithm::HierarchicalPAM::HierarchicalPAMModel $model = $lda.fit(:num-super-topics(3), :num-sub-topics(5), :num-iterations(1000));
    is $model.topic-word-matrix.shape, (3 + 3 * 5, 8);
    is $model.document-topic-matrix.shape, (2, 3 + 3 * 5);
    is $model.nbest-words-per-topic(9).shape, (3 + 3 * 5, 8), "n is greater than vocab size";
    is $model.nbest-words-per-topic(8).shape, (3 + 3 * 5, 8), "n is equal to the vocab size";
    is $model.nbest-words-per-topic(7).shape, (3 + 3 * 5, 7), "n is less than vocab size";
}, "Check resulting matrix shape";

subtest {
    my @documents = (
        "a b c d",
        "e f g h",
    );
    my ($documents, $vocabs) = Algorithm::HierarchicalPAM::Formatter.from-plain(@documents);
    my Algorithm::HierarchicalPAM $lda .= new(:$documents, :$vocabs);
    my Algorithm::HierarchicalPAM::HierarchicalPAMModel $model = $lda.fit(:num-super-topics(3), :num-sub-topics(5), :num-iterations(1000));
    is $model.vocabulary.elems, 8;
}, "Check vocabulary size";

subtest {
    my @documents = (
        ("a" .. "z").pick(100).join(" "),
        ("a" .. "z").pick(100).join(" "),
        ("a" .. "z").pick(100).join(" ")
    );
    my ($documents, $vocabs) = Algorithm::HierarchicalPAM::Formatter.from-plain(@documents);
    my Algorithm::HierarchicalPAM $lda .= new(:$documents, :$vocabs);

    my @prev;
    for 1..5 {
        my Algorithm::HierarchicalPAM::HierarchicalPAMModel $model = $lda.fit(:num-super-topics(3), :num-sub-topics(5), :num-iterations(1000), :seed(2));
        if @prev {
            is @prev, $model.document-topic-matrix;
        }
        @prev = $model.document-topic-matrix;
    }
}, "Check reproducibility";

done-testing;
