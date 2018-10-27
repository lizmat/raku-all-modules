# Web::Template

## Introduction

A simple abstraction layer, providing a consistent API for different
template engines. This is designed for use in higher level web frameworks
such as [Web::App::Ballet](https://github.com/supernovus/perl6-web-app-ballet/)
and [Web::App::MVC](https://github.com/supernovus/perl6-web-app-mvc/).

## Supported Template Engines

 * [Template6](https://github.com/supernovus/template6/)

   An engine inspired by Template Toolkit. Has many features.
   Wrapper is Web::Template::Template6

 * [Template::Mojo](https://github.com/tadzik/Template-Mojo/)

   A template engine inspired by Perl 5's Mojo::Template.
   Wrapper is Web::Template::Mojo

 * [HTML::Template](https://github.com/masak/html-template/)

   A template engine inspired by Perl 5's HTML::Template.
   Wrapper is Web::Template::HTML

## Broken Template Engines

 * [Flower::TAL](https://github.com/supernovus/flower/)

   An implementation of the TAL/METAL XML-based template languages from Zope.
   Wrapper is Web::Template::TAL

   I will get this fixed up when I can and re-add it to the list of supported
   template engines.

## Methods

All of the wrapper classes provide common API methods, so as long as your
web framework or application supports the following API, it doesn't have to
worry about the APIs of the individual template engines themselves.

### set-path ($path, ...)

Set the directory or directories to find the template files in.
For engines without native support of multiple search paths, or even
file-based templates to begin with, the wrapper classes add such support.

### render ($template, ...)

Takes the template name to render, and passes any additional parameters
through to the template engine. Most template engines use named parameters,
but some like Mojo, use positional parameters. This handles both.

## Usage

```perl

use Web::Template::TAL;
my $engine = Web::Template::TAL.new;
$engine.set-path('./views');
$engine.render('example.xml', :name<Bob>);

```

See one of the web application frameworks using this for better examples.

## TODO

 * Add a test suite with all supported template engines covered.
 * Add support for the Plosurin template engine.

## Author

[Timothy Totten](https://github.com/supernovus/) -- supernovus on #perl6

## License

[Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0)

