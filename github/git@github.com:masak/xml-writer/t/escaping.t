use v6;

use XML::Writer;
use Test;
plan 3;
ok XML::Writer.serialize('a' => [ :b<c>, '<foo>' ]) !~~ / '<foo>' /,
   'plain text is escaped (<>)';
given XML::Writer.serialize('a' => [ :b<c>, '&' ]) {
    ok  $_ ~~ / '&amp;' /,
    'plain text is escaped (&)'
        or diag "XML: $_";
}
ok XML::Writer.serialize('a' => [ :b<c>, 'a"b' ]) !~~ / 'a"b' /,
   'plain text is escaped (")';

