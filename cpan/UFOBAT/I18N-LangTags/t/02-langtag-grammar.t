use v6.c;
use I18N::LangTags::Actions;
use I18N::LangTags::Grammar;
use Test;

is I18N::LangTags::Grammar.parse(
    'en',
    :rule('langtag')),
'en';

is I18N::LangTags::Grammar.parse(
    'This is English',
    :rule('name')),
'This is English';

is I18N::LangTags::Grammar.parse(
    '{en} : This is English',
    :rule('language')),
'{en} : This is English';

is I18N::LangTags::Grammar.parse(
    '[{en} : This is English]'),
'[{en} : This is English]';

is I18N::LangTags::Grammar.parse(
    'noise [{en} : This is English] noise {de} : German',
    :rule('scan_languages')),
'noise [{en} : This is English] noise {de} : German';

# With actions
# a Pair
is-deeply I18N::LangTags::Grammar.parse(
    '{en} : This is English',
    :rule('language'),
    :actions(I18N::LangTags::Actions.new)).made,
{
    tag => 'en',
    name => 'This is English',
    is_disrec => False,
};

# TOP token
is-deeply I18N::LangTags::Grammar.parse(
    '[{en} : This is English]',
    :actions(I18N::LangTags::Actions.new)).made,
{
    tag => 'en',
    name => 'This is English',
    is_disrec => True
};

# example
is-deeply I18N::LangTags::Grammar.parse(
    'noise [{en} : This is English] noise {de} : German',
    :rule('scan_languages'),
    :actions(I18N::LangTags::Actions.new)).made,
(
    {:is_disrec(True), :name("This is English"), :tag("en")},
    {:is_disrec(False), :name("German"), :tag("de")}
);

# Things that did not work at first
is-deeply I18N::LangTags::Grammar.parse(
    '{sv-se} Sweden Swedish; {sv-fi} Finland Swedish.',
    :rule('scan_languages'),
    :actions(I18N::LangTags::Actions.new)).made,
(
    {:is_disrec(False), :name("Sweden Swedish"), :tag("sv-se")},
    {:is_disrec(False), :name("Finland Swedish"), :tag("sv-fi")}
);

is-deeply I18N::LangTags::Grammar.parse(
    '[{gem} : Germanic (Other)]',
    :rule('scan_languages'),
    :actions(I18N::LangTags::Actions.new)).made,
(
    {:is_disrec(True), :name("Germanic (Other)"), :tag("gem")},
);

is-deeply I18N::LangTags::Grammar.parse(
    '[{cpf} : French-based Creoles and pidgins (Other)]',
    :rule('scan_languages'),
    :actions(I18N::LangTags::Actions.new)).made,
(
    {:is_disrec(True), :name("French-based Creoles and pidgins (Other)"), :tag("cpf")},
);

is I18N::LangTags::Grammar.parse(
    'i-tao',
    :rule('langtag')),
'i-tao';

is I18N::LangTags::Grammar.parse(
    'it',
    :rule('langtag')),
'it';

is I18N::LangTags::Grammar.parse(
    '{it} : Italian',
    :rule('language')),
'{it} : Italian';

is I18N::LangTags::Grammar.parse(
    'i',
    :rule('langtag')),
Nil;

is I18N::LangTags::Grammar.parse(
    'x-borg-prot5123',
    :rule('langtag')),
'x-borg-prot5123';
done-testing;
