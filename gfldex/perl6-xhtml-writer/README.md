# XHTML::Writer
[![Build Status](https://travis-ci.org/gfldex/perl6-xhtml-writer.svg?branch=master)](https://travis-ci.org/gfldex/perl6-xhtml-writer)

Write xhtml elements utilising named arguments to guard against typos. Colons in
names of XHTML attributes are replaced with a hyphen (e.g. `xml:lang`). Use the the html element names
as an import tag or `:ALL` to get them all. Please note that there is a `dd`-tag what will
overwrite `dd` from the settings.

The actual module is generated form the official XHTML 1.1 Schema. There is no offical
XML Schema for HTML5 (because it isn't XML), if you happen to come a cross one that works
please let me know.

## Usage:
```
use v6;
use XHTML::Writer :ALL;

put html( xml-lang=>'de', 
	body(
        div( id=>"uniq",
          p( class=>"abc", 'your text here'),
          p( 'more text' )
        )
    ));
```

With skeleton:

```
use v6;
use XHTML::Writer :p, :title;
use XHTML::Skeleton;

put xhtml-skeleton(p('Hello Camelia!'), header=>title('Hello Camelia'));
```

## License

(c) Wenzel P. P. Peppmeyer, Released under Artistic License 2.0.
