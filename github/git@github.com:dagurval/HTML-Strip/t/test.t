#!/usr/bin/env perl6
use v6;
use lib '../lib';

use HTML::Strip;
use Test;
plan 27;

my $html = q{<html>simple test</html>};
is strip_html($html), "simple test ", "simple strip";

$html = q{<html>< !-- some comment <a>anchor</a>-->text</html>};
is strip_html($html), "text ", "ignore comment";

$html = q{<html><style>ignore me</style>keep me};
is strip_html($html), "keep me", "basic tag strip";

is strip_html('&invalid;&encoded;&string;'), '&invalid;&encoded;&string;', "Invalid encoding";

is strip_html('<script type="javascript">ignore me</script>hello world</a>'), 'hello world ', 'javascript tag';

is strip_html('<SCRIPT>hello</script>world'), 'world', 'upper case';

# Below are tests originally ported from the Perl5 module HTML::Strip
# http://search.cpan.org/~kilinrax/HTML-Strip-1.06/Strip.pm

is strip_html('test' ), 'test';
is strip_html('<em>test</em>'), 'test ' ;
is strip_html('foo<br>bar'), 'foo bar' ;
is strip_html('<p align="center">test</p>'), 'test ' ;
is strip_html('<p align="center>test</p>'), 'test ', "bad html" ;
is strip_html('<foo>bar' ), 'bar' ;
is strip_html('</foo>baz' ), 'baz', 'tag quickend' ;
is strip_html('<!-- <p>foo</p> bar -->baz' ), 'baz' ;
#is strip_html('<img src="foo.gif" alt="a > b">bar' ), 'bar' ;
is strip_html('<script>if (a<b && a>c)</script>bar' ), 'bar' ;
is strip_html('<# just data #>bar' ), 'bar' ;
is strip_html('<script>foo</script>bar' ), 'bar' ;

is strip_html( '&#060;foo&#062;' ), '<foo>' ;
is strip_html( '&lt;foo&gt;' ), '<foo>' ;

is strip_html('&#060;foo&#062;', :decode_entities(False)), '&#060;foo&#062;' ;
is strip_html('&lt;foo&gt;', :decode_entities(False)), '&lt;foo&gt;' ;


my @s = <foo>;

is strip_html( '<script>foo</script>bar', :strip_tags(@s)), 'foo bar' ;
is strip_html( '<foo>foo</foo>bar', :strip_tags(@s) ), 'bar';
is strip_html( '<script>foo</script>bar' ), 'bar' ;

@s = <baz quux>;
is  strip_html('<baz>fumble</baz>bar<quux>foo</quux>', :strip_tags(@s)), 'bar' ;
is  strip_html('<baz>fumble<quux/>foo</baz>bar', :strip_tags(@s)), 'bar' ;
is  strip_html('<foo> </foo> <bar> baz </bar>' , :strip_tags(@s)), '   baz ' ;

