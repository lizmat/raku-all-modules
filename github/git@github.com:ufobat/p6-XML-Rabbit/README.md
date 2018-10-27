# XML::Rabbit

[![Build Status](https://travis-ci.org/ufobat/p6-XML-Rabbit.png)](https://travis-ci.org/ufobat/p6-XML-Rabbit)

A Perl 6 Library for building Attribues from XML files with xpath Expressions.

# XPath Specification

Specification on XPath Expressions can be found at <https://www.w3.org/TR/xpath/>.

# Synopsis

```Perl6

use XML::Rabbit;

class MyClass does XML::Rabbit::Node {
    has $.x is xpath-object('MyOtherClass, '/xml/b/@key' => '/xml/b');
}

class MyOtherClass does XML::Rabbit::Node {
    has $.value is xpath('.');
    has $.key is xpath('./@key');
}

my $object = MyClass.new(file => '/path/to/file.xml');

```

# Example

If you want to see more examples please have a look at the [testcases](t).

# Documentation

This is my attempt to bring the ideas of [perl5 XML::Rabbit](https://metacpan.org/pod/XML::Rabbit) into perl6. Thanks to [AttrX::Lazy](https://github.com/pierre-vigier/Perl6-AttrX-Lazy) where I got the blueprint how to do the Meta programming.

# License

Artistic License 2.0.
