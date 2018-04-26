#!perl6

use v6;

use Test;
use HTTP::Headers;

my $h = HTTP::Headers.new;

$h.header("CONTENT_LENGTH", :quiet) = 'text/html';
is $h.Content-Length, 'text/html', 'CONTENT_LENGTH -> Content-Length';

$h.header('X_FOO') = 'Bar';
is $h.header('X-Foo'), 'Bar', 'X_FOO -> X-Foo';

is $h.as-string, q:to/END_OF_HEADERS/, 'as-string as expected';
Content-Length: text/html
X-Foo: Bar
END_OF_HEADERS

done-testing;
