use v6;
use Test;
use Algorithm::NaiveBayes;

{
    use Algorithm::NaiveBayes::Vocabulary;
    my $vocab = Algorithm::NaiveBayes::Vocabulary.new(attributes => {"pong" => 3});
    is $vocab.attributes, {"pong" => 3};
}

{
    use Algorithm::NaiveBayes::Vocabulary;
    my $vocab = Algorithm::NaiveBayes::Vocabulary.new(:text("pong pong pong"));
    is $vocab.attributes, {"pong" => 3};
}

{
    use Algorithm::NaiveBayes::Vocabulary;
    my $vocab = Algorithm::NaiveBayes::Vocabulary.new(:words(Array[Str].new("pong", "pong", "pong")));
    is $vocab.attributes, {"pong" => 3};
}

{
    use Algorithm::NaiveBayes::Document;
    my $doc = Algorithm::NaiveBayes::Document.new(attributes => {"pong" => 3});
    is $doc.vocabulary.attributes, {"pong" => 3};
}

{
    use Algorithm::NaiveBayes::Document;
    my $doc = Algorithm::NaiveBayes::Document.new(text => "pong pong pong");
    is $doc.vocabulary.attributes, {"pong" => 3};
}

{
    use Algorithm::NaiveBayes::Document;
    my $doc = Algorithm::NaiveBayes::Document.new(words => Array[Str].new("pong", "pong", "pong"));
    is $doc.vocabulary.attributes, {"pong" => 3};
}

{
    my $nb = Algorithm::NaiveBayes.new(solver => Algorithm::NaiveBayes::Multinomial);
    $nb.add-document("Chinese Beijing Chinese", "China");
    $nb.add-document("Chinese Chinese Shanghai", "China");
    $nb.add-document("Chinese Macao", "China");
    $nb.add-document("Tokyo Japan Chinese", "Japan");
    $nb.train();
    is $nb.word-given-class("Chinese", "China"), 3/7, "P(Chinese|China)";
    is $nb.word-given-class("Tokyo", "China"), 1/14, "P(Tokyo|China)";
    is $nb.word-given-class("Japan", "China"), 1/14, "P(Japan|China)";
    my @result = $nb.predict("Chinese Chinese Chinese Tokyo Japan");
    is @result[0].key, "China";
    is @result[0].value, log(3/4 * (3/7) ** 3 * 1/14 * 1/14), "P(China|doc)";
    is @result[1].key, "Japan";
    is @result[1].value, log(1/4 * (2/9) ** 3 * 2/9 * 2/9), "P(Japan|doc)";
}

{
    my $nb = Algorithm::NaiveBayes.new(solver => Algorithm::NaiveBayes::Bernoulli);
    $nb.add-document("Chinese Beijing Chinese", "China");
    $nb.add-document("Chinese Chinese Shanghai", "China");
    $nb.add-document("Chinese Macao", "China");
    $nb.add-document("Tokyo Japan Chinese", "Japan");
    $nb.train();
    is $nb.word-given-class("Chinese", "China"), 4/5, "P(Chinese|China)";
    is $nb.word-given-class("Japan", "China"), 1/5, "P(Japan|China)";
    is $nb.word-given-class("Tokyo", "China"), 1/5, "P(Tokyo|China)";
    is $nb.word-given-class("Beijing", "China"), 2/5, "P(Beijing|China)";
    is $nb.word-given-class("Shanghai", "China"), 2/5, "P(Shanghai|China)";
    is $nb.word-given-class("Macao", "China"), 2/5, "P(Macao|China)";
    
    my @result = $nb.predict("Chinese Chinese Chinese Tokyo Japan");
    is @result[0].key, "Japan";
    is @result[0].value, log(1/4 * 2/3 * 2/3 * 2/3 * (1 - 1/3) * (1 - 1/3) * (1 - 1/3)), "P(Japan|doc)";

    is @result[1].key, "China";
    is @result[1].value, log(3/4 * 4/5 * 1/5 * 1/5 * (1 - 2/5) * (1 - 2/5) * (1 - 2/5)), "P(China|doc)";
}

done-testing;
