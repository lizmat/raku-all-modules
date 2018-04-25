use v6.c;
use Test;

use I18N::LangTags;

for ('C', 'POSIX') {
    my $tag = locale2language_tag($_);
    is $tag, Str, "locale2language_tag('$_')";
}
for (
    ['en', 'en'],
    ['en_US', 'en-us'],
    ['en_US.ISO8859-1', 'en-us'],
    ['eu_mt', 'eu-mt'],
    ['eu', 'eu'],
    ['it', 'it'],
    ['it_IT', 'it-it'],
    ['it_IT.utf8', 'it-it'],
    ['it_IT.utf8@euro', 'it-it'],
    ['it_IT@euro', 'it-it'],
    ['zh_CN.gb18030', 'zh-cn'],
    ['zh_CN.gbk', 'zh-cn'],
    ['zh_CN.utf8', 'zh-cn'],
    ['zh_HK', 'zh-hk'],
    ['zh_HK.utf8', 'zh-hk'],
    ['zh_TW', 'zh-tw'],
    ['zh_TW.euctw', 'zh-tw'],
    ['zh_TW.utf8', 'zh-tw'],
) -> ($tag, $expect) {
    is locale2language_tag($tag).lc, $expect, "locale2language_tag('$tag')";
}

done-testing;
