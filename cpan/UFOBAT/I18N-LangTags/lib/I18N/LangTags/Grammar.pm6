use v6.c;

grammar I18N::LangTags::Grammar {
    token TOP { <disrec_language> | <language> }
    token disrec_language { '[' <language> ']' }
    token language { '{' <langtag> '}' \h+ [ ':' \h+]? <name> }
    regex langtag {
        [ [ 'i' | 'x' ] [ '-' <alnum> ** 1..8] + ]
        |
        [ [<alpha> ** 2..3]  [ '-' <alnum> ** 1..8] * ]
    }
    token name { <[\w\s\-()]>+ }

    regex scan_languages { [ .*? <TOP> .*?]+  }
    regex scan_langtags  { [ .*? <|w> <langtag> <|w> .*? ]+ }
    regex formerly { .*? 'Formerly "' <langtag> '"' .*? }
}
