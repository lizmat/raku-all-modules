use v6;
use Test;

use lib 'lib';
use MIME::QuotedPrint;

plan 2;

my Str $x = MIME::QuotedPrint.encode-str('asdf=jkl');
is $x, 'asdf=3Djkl', 'encoding';
$x = MIME::QuotedPrint.decode-str($x);
is $x, 'asdf=jkl', 'roundtrippable';
