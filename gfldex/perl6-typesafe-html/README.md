# Typesafe::HTML
[![Build Status](https://travis-ci.org/gfldex/perl6-typesafe-html.svg?branch=master)](https://travis-ci.org/gfldex/perl6-typesafe-html)

Baseclass to be used with Typesafe::XHTML::Writer. It overloads `infix:<~>` to
guard against omision of HTML-entity quotation. This is not a DOM
Implementation, it's merely a secure way to concatanate HTML and non-HTML
strings. It's lightweight by design, resulting in fairly good speed.

The only characters that are turned into HTML-Entities are `<` and `&`. If you
need more use a modules that does not focus on speed.

## Usage:
```
use v6;
use Typesafe::HTML;

my $html = HTML.new('<p>this will not be quoted</p>');
$html ~= '<p>this will</p>';
$html = $html ~ '& this will also be quoted';
$html = '& this prefix too' ~ $html;

dd $html;

# OUTPUT: HTML $html = HTML.new('&amp; this prefix too<p>this will not be quoted</p>&lt;p>this will&lt;/p>&amp; this will also be quoted');


$html = HTML.new ~ '& more quoting';

dd $html;

# OUTPUT: HTML $html = HTML.new('&amp; more quoting');

put $html.Str;

# OUTPUT: &amp; more quoting
```

## License

(c) Wenzel P. P. Peppmeyer, Released under Artistic License 2.0.
