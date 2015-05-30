#!perl6

use v6;

use Test;
use HTTP::Headers;

my $h = HTTP::Headers.new;
$h.Content-Type = 'text/html; charset=UTF-8';
is($h.Content-Type.primary, 'text/html');
is($h.Content-Type.charset, 'UTF-8');
$h.Content-Type.charset = 'ISO-8859-1';
is(~$h.Content-Type, 'text/html; charset=ISO-8859-1');
$h.Content-Type.charset = Nil;
is(~$h.Content-Type, 'text/html');
$h.Content-Type.charset = 'Latin1';
is(~$h.Content-Type, 'text/html; charset=Latin1');
is($h.Content-Type.is-html, True);
is($h.Content-Type.is-text, True);
is($h.Content-Type.is-xhtml, False);
is($h.Content-Type.is-xml, False);

done;
