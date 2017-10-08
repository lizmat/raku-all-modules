NAME
====

Text::Spintax

SYNOPSIS
========

A parser and renderer for spintax formatted text.

    use Text::Spintax;

    my $node = Text::Spintax.new.parse('This {is|was|will be} some {varied|random} text');
    my $text = $node.render;

DESCRIPTION
===========

Text::Spintax implements a parser and renderer for spintax formatted text. Spintax is a commonly used method for generating "randomized" text. For example,

    This {is|was} a test

would be rendered as

    * This is a test
    * This was a test

Spintax can be nested indefinitely, for example:

    This is nested {{very|quite} deeply|deep}.

would be rendered as

    * This is nested very deeply.
    * This is nested quite deeply.
    * This is nested deep.

AUTHOR
======

Dale Evans, `<daleevans@github> ` http://devans.mycanadapayday.com

BUGS
====

Please report any bugs or feature requests at [https://github.com/daleevans/perl6-Text-Spintax/issues](https://github.com/daleevans/perl6-Text-Spintax/issues)

SUPPORT
=======

You can find documentation for this module with the p6doc command.

    p6doc Text::Spintax

class Text::Spintax::Spintax
----------------------------

a parser and renderer for spintax formatted text built using Perl6 grammar
