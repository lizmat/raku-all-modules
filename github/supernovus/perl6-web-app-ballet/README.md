# Web::App::Ballet

## Introduction

An extension to [Web::App](https://github.com/supernovus/perl6-web/) which
adds an interface similar to Dancer or Bailador.

NOTE: I am reworking this module to be merged with Bailador.
A lot of Bailador is duplicating the work done in the Web project, and
so I have agreed to work with tadzik to merge these two projects together.
I am currently adding any of Bailador's features that are missing, and will
then work with tadzik to make any transition required to merge the projects.

## Supported Transports

Technically, it can use any backend transport that Web::App supports, 
but there are only convenience wrappers provided for the following:

 * [SCGI](https://github.com/supernovus/SCGI/)

   The fastest way to connect to a web server such as Apache or lighttpd.
   Type 'use-scgi' in your application to use this.

 * [HTTP::Easy](https://github.com/supernovus/perl6-http-easy/)

   A standalone HTTP server, useful for testing your in-development apps.
   Type 'use-http' in your application to use this.
   This is the default choice if you don't specify another option.

## Supported Template Engines

We are using [Web::Template](https://github.com/supernovus/perl6-web-template/)
as our template engine abstraction layer, and will support any engines that it
has wrapper classes for. The currently supported libraries are:

 * [Template6](https://github.com/supernovus/template6/)

   An engine inspired by Template Toolkit. Has many features.
   Type 'use-template6' in your application to use this engine.
   This is the default choice if you don't specify another option.

 * [Flower::TAL](https://github.com/supernovus/flower/)

   An implementation of the TAL/METAL XML-based template languages from Zope.
   Type 'use-tal' in your application to use this engine.

 * [Template::Mojo](https://github.com/tadzik/Template-Mojo/)

   A template engine inspired by Perl 5's Mojo::Template.
   Type 'use-mojo' in your application to use this engine.

 * [HTML::Template](https://github.com/masak/html-template/)

   A template engine inspired by Perl 5's HTML::Template.
   Type 'use-html' in your application to use this engine.

## Example Application Script

```perl
  use Web::App::Ballet;

  use-template6; ## We're explicitly setting the template engine.

  get '/' => sub ($c) {
    $c.content-type: 'text/plain';
    my $name = $c.get(:default<World>, 'name');
    $c.send("Hello $name"); ## Explicit context output specified.
  }

  get '/perl6' => 'http://perl6.org/'; ## A redirect statement.

  get '/hello/:name' => sub ($c) {
    my $name = $c.get(':name'); ## get the placeholder path.
    $c.send(template('hello', :$name)); ## Explicit template output.
  }

  get '/about' => sub ($c) {
    template 'about', :ver<1.0.0>; ## Implicit template output.
  }

  dance; ## Start the process.

```

## TODO

 * Add testing ability once Web::App has testing support added.

## Author

[Timothy Totten](https://github.com/supernovus/) -- supernovus on #perl6

## License

[Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0)

