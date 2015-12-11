[![Build Status](https://travis-ci.org/Skarsnik/perl6-gumbo.svg?branch=master)](https://travis-ci.org/Skarsnik/perl6-gumbo)

Name Gumbo
==========

Synopsis
========

    use Gumbo;
    use LWP::Simple;

    my $xml = parse-html(LWP::Simple.get("www.google.com"));
    say $xml.lookfor(:TAG<title>); # Google;

Description
===========

From the Gumbo project page :

Gumbo is an implementation of the HTML5 parsing algorithm implemented as a pure C99 library with no outside dependencies. It's designed to serve as a building block for other tools and libraries such as linters, validators, templating languages, and refactoring and analysis tools.

This module is a binding to this library. It provide a `parse-html` routine that parse a given html string and return a `XML::Document` object. To access all the Gumbo library has to offer you probably want to look at the `Gumbo::Binding` module.

Usage
=====

parse-html(Str $html) : XML::Document 
--------------------------------------

Parse a html string and retrurn a `XML::Document`. 

parse-html(Str $html, :$nowhitespace, *%filters) : XML::Document
----------------------------------------------------------------

This is the full signature of the `parse-html` routine.

  * nowhitespace

Tell Gumbo to not include all extra whitespaces that can exist around tag, like intendation put in front of html tags

  * *%filters

The module offer some form of basic filtering if you want to restrict the `XML::Document` returned.  You can only filter on elements (understand tags) and not content like the text of a `p` tag.

It inspired by the `elements` method of the `XML::Element` class. The main purpore is to reduce time spent parsing uneccessary content and decrease the memory print of the `XML::Document`.

IMPORTANT: the root will always be the html tag.

  * TAG Limits to elements with the given tag name

  * SINGLE If set only get the first match

  * attrib You can filter on one attribute name with his given value

All the children of the element(s) matched are kept. Like if you search for all the links, you will get the eventuals additionals tags put around the text part.

$gumbo_last_c_parse_duration && $gumbo_last_xml_creation_duration
-----------------------------------------------------------------

These two variables hold the time (`Duration`) spend in the two steps of the work parse-html does.

Example
=======

    use Gumbo;

    my $html = q:to/END_HTML/;
    <html>
    <head>
           <title>Fancy</title>
    </head>
    <body>
           <p>It's fancy</p>
           <p class="fancier">It's fancier</p>
    </body>
    </html>

    END_HTML

    my $xmldoc = parse-html($html);

    say $xmldoc.root.elements(:TAG<p>, :RECURSE)[0][0].text; #It's fancy

    $xmldoc = parse-html($html, :TAG<p>, :SINGLE);

    say $xmldoc[0][0].text; #It's still fancy

    $xmldoc = parse-html($html, :TAG<p>, :class<fancier>, :SINGLE);

    say $xmldoc[0][0].text; # It's fancier

Gumbo::Parser
=============

This module provide a Gumbo::Parser class that does the role defined by the `HTML::Parser` module. It also provide some additionnals attributes that contains various informations. It work exactly like the `parse-html` method with the same extra optionnals arguments.

    use Gumbo::Parser;

    my $parser = Gumbo::Parser.new;
    my $xmldoc = $parser->parse($html);
    say $parser.c-parse-duration;
    say $parser.xml-creation-duration;
    say $parser.stats<xml-objects>; # the number of XML::* created (excluding the XML::Document)
    say $parser.stats<whitespaces>; # the number of Whitespaces elements (created or not)
    say $parser.stats<elements>; # the number of XML::Element (including root)

See Also
========

`XML`, `HTML::Parser::XML`

Copyright
=========

Sylvain "Skarsnik" Colinet <scolinet@gmail.com>

License
=======

The modules provided by Gumbo are under the same licence as Rakudo
