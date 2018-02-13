use Test;
use MeCab;
use MeCab::DictionaryInfo;
use MeCab::Tagger;

subtest {
    my MeCab::Tagger $tagger .= new("-C");
    my MeCab::DictionaryInfo $dictionary-info = $tagger.dictionary-info;
    is $dictionary-info.filename, "$*HOME/.p6mecab/lib/mecab/dic/ipadic/sys.dic";
    is $dictionary-info.charset, "utf8";
    is $dictionary-info.size, 392126;
    is $dictionary-info.type, MECAB_SYS_DIC;
    is $dictionary-info.lsize, 1316;
    is $dictionary-info.rsize, 1316;
    is $dictionary-info.version, 102;
}, "MeCab::DictionaryInfo should have all <filename size type lsize rsize version>";

done-testing;
