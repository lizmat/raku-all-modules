use v6.c;
use I18N::LangTags::List;
use I18N::LangTags;
use Test;

for (
    ['', False],
    ['fr', True],
    ['fr-ca', True],
    ['fr-CA', True],
    ['fr-CA-', False],
    ['fr_CA', False],
    ['fr-ca-joal', True],
    ['frca', False],
    ['nav', True, 'not actual tag'],
    ['nav-shiprock', True, 'not actual tag'],
    ['nav-ceremonial', False, 'subtag too long'],
    ['x', False],
    ['i', False],
    ['i-borg', True, 'fictitious tag'],
    ['x-borg', True],
    ['x-borg-prot5123', True],
) -> ($tag, $expect, $note is copy = '') {
    $note = " # $note" if $note;
    is is_language_tag($tag), $expect, "is_language_tag('$tag')$note";
}

is same_language_tag('x-borg-prot5123', 'i-BORG-Prot5123'), True;
is same_language_tag('en', 'en-us'), False;

is similarity_language_tag('en-ca', 'fr-ca'), 0;
is similarity_language_tag('en-ca', 'en-us'), 1;
is similarity_language_tag('en-us-southern', 'en-us-western'), 2;
is similarity_language_tag('en-us-southern', 'en-us'), 2;

ok  'hi' ∈ panic_languages('kok');
ok  'en' ∈ panic_languages('x-woozle-wuzzle');
nok 'mr' ∈ panic_languages('it');
ok  'es' ∈ panic_languages('it');
ok  'it' ∈ panic_languages('es');

use I18N::LangTags::List;
for (q:w|
 en
 en-us
 en-kr
 el
 elx
 i-mingo
 i-mingo-tom
 x-mingo-tom
 it
 it-it
 it-IT
 it-FR
 ak
 aka
 jv
 jw
 no
 no-nyn
 nn
 i-lux
 lb
 wa
 yi
 ji
 den-syllabic
 den-syllabic-western
 den-western
 den-latin
 cre-syllabic
 cre-syllabic-western
 cre-western
 cre-latin
 cr-syllabic
 cr-syllabic-western
 cr-western
 cr-latin
|) -> $lt {
    my $name = I18N::LangTags::List::name($lt);
    ok $name.defined, "I18N::LangTags::List::name('$lt')";
}

done-testing;
