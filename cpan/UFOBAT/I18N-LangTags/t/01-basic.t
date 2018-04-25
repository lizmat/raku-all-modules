use v6.c;
use Test;
use I18N::LangTags;

is extract_language_tags("de-at, en or something x"),
('de-at', 'en', 'or');

done-testing;
