use v6.c;
use I18N::LangTags::List;
use Test;

# not a language tag
is I18N::LangTags::List::name('x  fr'), Nil;
nok I18N::LangTags::List::name('El Zorcho');

is I18N::LangTags::List::name('fr'), 'French';
is I18N::LangTags::List::name('fr-fr'), 'France French';


# not a language tag
nok I18N::LangTags::List::is_decent('  fr');
nok I18N::LangTags::List::is_decent('x  fr');

for (
    ['fr', True],
    ['fr-blorch', True],
    ['El Zorcho', False],
    ['sgn', False],
    ['sgn-us', True],
    ['i', False],
    ['i-mingo', True],
    ['i-mingo-tom', True],
    ['cel', False],
    ['cel-gaulish', True],
) -> ($tag, $expectation) {
    is I18N::LangTags::List::is_decent($tag), $expectation;

}

done-testing;
