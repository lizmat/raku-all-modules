# XML::Query

## Introduction

XML::Query is a jQuery-like XML query engine for Perl 6.
It works with the [XML](https://github.com/supernovus/exemel) library 
to provide a flexible and easy method of querying for specific XML/XHTML nodes.

Unlike jQuery, XML::Query is for querying and travsersing XML structures only, 
and does not support direct manipulation of XML data (however you can use the
features inherent to the XML library to manipulate the data.)

## Synopsis

```perl
  ## Given $xml is an XML::Document or XML::Element object.
  my $xq = XML::Query.new($xml);
  my @boxes = $xq('input[type="radio"]').not('[disabled="disabled"]').elements;
  my $first-link = $xq('a').first.element; 
  my $by-id = $xq('#header').element;
  my $last-decr-class = $xq('.decr').last.element; 
```

## Status

This is a work in progress. It doesn't support many methods or selectors yet,
and there is no documentation. See the tests in the "t/" folder for examples
of what does work so far.

## Author

[Timothy Totten](https://github.com/supernovus/)

## License

[Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0)

