# Gumbo perl6 binding

## Introduction

From the Gumbo project page :

Gumbo is an implementation of the HTML5 parsing algorithm implemented as a pure C99 library with no outside dependencies. It's designed to serve as a building block for other tools and libraries such as linters, validators, templating languages, and refactoring and analysis tools.


This binbiding only provide a parse-html function that call the main function of gumbo (gumbo_parse) and return a XML::Document object

## Example

```perl
use Gumbo;

my $html = q:to/END_HTML/;
<html>
<head>
        <title>Fancy</title>
</head>
<body>
        <p>It's fancy</p>
</body>
</html>

END_HTML

my $xmldoc = parse-html($html);

say $xmldoc.root.elements(:TAG<p>, :RECURSE<5>)[0][0]; #It's fancy

# The Gumbo module provide you two variables to look at the duration of the process

say "Time spend in the gumbo_parse call     : ", $gumbo_last_c_parse_duration;
say "Time spend creating the XML::Document, : ", $gumbo_last_xml_creation_duration;

```

## Warning

The XML::Document include all whitespace. That why in the previous example, the 'p' element is not acceded with $xmldoc.root[1][0][0]

Etheir use the XML::Element.elements method (eg: $xmldoc.root.elements[1].elements[0][0]) or the search form of the method.

## Filters

The module offer some form of basic filtering if you want to restrict the `XML::Document` returned. You can only filter on elements (understand tags) and not content like the text of a `<p>` tag.

The `XML::Element.elements` method provide a more complete set of filter. Having filters here is mainly for performance by reducing the number of XML objects created.

IMPORTANT: the root will always be the html tag.

`parse-html($html, ...)`

  * TAG
    Limite to elements with the given tag name

  * SINGLE
    If set only get the first match

  * attrib
    You can filter on one attribute name with his given value


All the children of the element(s) matched are kept. Like if you search for all the links, you will get the eventuals additionals tags put around the text part.


### Example

```perl
parse-html($html, :TAG<a>); # if you want only all the 'a' tag
parse-html($html, :TAG<div>, :class<banner>); # will only have 'div' tag having the attribute 'class' holding the value banner.
parse-html($html, :TAG<div>, :class<banner>, :SINGLE); #will stop at the first one
```



## Contact

Contact me at scolinet@gmail.com if you have any question.
