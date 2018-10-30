# XML::XPath

[![Build Status](https://travis-ci.org/ufobat/p6-XML-XPath.png)](https://travis-ci.org/ufobat/p6-XML-XPath)
[![Build status](https://ci.appveyor.com/api/projects/status/github/ufobat/p6-XML-XPath?svg=true)](https://ci.appveyor.com/project/ufobat/p6-XML-XPath/branch/master)

A Perl 6 Library for parsing and evaluating XPath Statements.

# XPath Specification

Specification on XPath Expressions can be found at <https://www.w3.org/TR/xpath/>.

# Synopsis

```Perl6

use XML::XPath;

my $xpath  = XML::XPath.new(xml => '... xml ...');
my $result = $xpath.find('/foo/bar');

```

# Example

If you want to see more examples please have a look at the [testcases](t).

# Documentation

## `XML::XPath.new(:$file, :$xml, :$document)`

XML::XPath creates a XML Document from a `$file` or from `$xml` unless you provide a `$document` in the constructor.

## `.find(Str $xpath, XML::Node :$start, Bool :$to-list)`

Evaluates the XPath Expression and returns the results of the match. If a $start node is provided it starts
there instead of beginning of the XML Document. 
If $to-list is True the result will allways be an Array, otherwise it might return Any or a single element
(e.g XML::Node, Str, Nummeric, Bool)

## `.set-namespace(Pair $ns)`

This method sets a namespace, so the value of `$ns.key` can be used in the XPath expression to look nodes a
certain namespace.

```Perl6

$x.set-namespace: 'goo' => "foobar.example.com";
$set = $x.find('//goo:something');

```

## `.clear-namespaces`

Clears all namespaces that have been set via `.set-namespace`. 

## `.parse-xpath(Str $xpath)`

Just parses `$xpath` expression.

# License

Artistic License 2.0.

