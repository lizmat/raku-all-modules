perl6-CSS-Specification
=======================
This is a Perl 6 module for parsing CSS property definitions.

These are widely used throughout the W3C CSS Specifications to describe properties.
The syntax is described in http://www.w3.org/TR/CSS21/about.html#property-defs.

An example, from http://www.w3.org/TR/CSS21/propidx.html:

    'content'	normal
               | none
               | [  <string> | <uri> | <counter> | attr(<identifier>)
                  | open-quote | close-quote | no-open-quote | no-close-quote
                 ]+
               | inherit

## Grammars and Classes

- `CSS::Specification::Build` is class for generating Perl&nbsp;6 grammar, actions or roles from sets of CSS property definitions.

This module also provides some mixin grammars and actions as follows:

- `CSS::Specification::Terms` + `CSS::Specification::Terms::Actions` - is a grammar which maps property specification terminology to CSS Core syntax and defines any newly introduced terms. For example `integer` is mapped to `int`.

## Programs
This module provides `css-gen-properties`. A program for translating property definitions
to grammars, actions or interface classes.

## See Also
See [make-modules.pl](https://github.com/p6-css/perl6-CSS-Module/blob/master/make-modules.pl) in [CSS::Module](https://github.com/p6-css/perl6-CSS-Module).
