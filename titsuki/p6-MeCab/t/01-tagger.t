use v6;
use Test;
use NativeCall;
use MeCab;
use MeCab::Tagger;

lives-ok { my $mecab-tagger = MeCab::Tagger.new('-C'); }

lives-ok { my $mecab-tagger = MeCab::Tagger.new; }

subtest {
    {
        my Str $text = "すもももももももものうち。";
        my $mecab-tagger = MeCab::Tagger.new('-C');
        my @surfaces = gather loop ( my MeCab::Node $node = $mecab-tagger.parse-tonode($text); $node; $node = $node.next ) {
            take $node.surface;
        }
        is @surfaces, ("","すもも","も","もも","も","もも","の","うち","。","");
    }
    
    {
        my Str $text = "すもももももももものうち。";
        my $mecab-tagger = MeCab::Tagger.new('-C');
        my @features = gather loop ( my $node = $mecab-tagger.parse-tonode($text); $node; $node = $node.next ) {
            take $node.feature;
        }
        is @features, ('BOS/EOS,*,*,*,*,*,*,*,*',
                       '名詞,一般,*,*,*,*,すもも,スモモ,スモモ',
                       '助詞,係助詞,*,*,*,*,も,モ,モ',
                       '名詞,一般,*,*,*,*,もも,モモ,モモ',
                       '助詞,係助詞,*,*,*,*,も,モ,モ',
                       '名詞,一般,*,*,*,*,もも,モモ,モモ',
                       '助詞,連体化,*,*,*,*,の,ノ,ノ',
                       '名詞,非自立,副詞可能,*,*,*,うち,ウチ,ウチ',
                       '記号,句点,*,*,*,*,。,。,。',
                       'BOS/EOS,*,*,*,*,*,*,*,*');
    }
}, "MeCab::Tagger.parse-tonode should return a fulfilled MeCab::Node object.";

done-testing;
