# Typesafe::XHTML::Writer
[![Build Status](https://travis-ci.org/gfldex/perl6-typesafe-xhtml-writer.svg?branch=master)](https://travis-ci.org/gfldex/perl6-typesafe-xhtml-writer)

Write XHTML elements utilising named arguments to guard against typos. Colons
in names of XHTML attributes are replaced with a hyphen (e.g. `xml:lang`). Use
the html element names as an import tag or `:ALL` to get them all. Please
note that there is a `dd`-tag what will overwrite `dd` from the settings.

The actual module is generated form the official XHTML 1.1 Schema. There is no
offical XML Schema for HTML5 (because it isn't XML), if you happen to come
across one that works please let me know.

It uses [Typesafe::HTML](https://github.com/gfldex/perl6-typesafe-xhtml-writer)
to guard against lack of quoting of HTML-tags. As a dropin-replacement of
`HTML::Writer`, it's about 5% slower then the former. For now neither `HTML`
nor `HTML::utf8-to-htmlentity()` can be overloaded. You can replace the entire
module to get the same result.

[`Typesafe::HTML::Skeleton`](https://raw.githubusercontent.com/gfldex/perl6-typesafe-xhtml-writer/master/lib/Typesafe/XHTML/Skeleton.pm6)
provides the routine `xhtml-skeleton` that takes instances of `HTML` (the type)
as parameters and returns `HTML`. The named arguments takes a single or a list
of tags of type `HTML` to be added to the header of the resulting XHTML
document. `HTML` is a flat eager string that is about 5% slower then without
typesafety. If you need a DOM use a module that does not focus on speed.


## Usage:
```
use v6;
use Typesafe::XHTML::Writer :ALL;

put html( xml-lang=>'de', 
	body(
        div( id=>"uniq",
          p( class=>"abc", 'your text here'),
          p( 'more text' ),
          '<p>this will be quoted with &lt; and &amp;</p>'
        )
    ));

put span('<b>this will also be quoted with HTML-entities</b>');
```

With skeleton:

```
use v6;
use Typesafe::XHTML::Writer :p, :title;
use Typesafe::XHTML::Skeleton;

put xhtml-skeleton(
        p('Hello Camelia!', class=>'foo'),
        'Camelia can quote all the <<<< and &&&&.', 
        header=>(title('Hello Camelia'), style('p.foo { color: #fff; }' ))
    );
```

## License

(c) Wenzel P. P. Peppmeyer, Released under Artistic License 2.0.
