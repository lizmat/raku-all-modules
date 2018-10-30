# Pod::To::HTML

[![Build Status](https://travis-ci.org/perl6/Pod-To-HTML.svg?branch=master)](https://travis-ci.org/perl6/Pod-To-HTML)

Render Perl 6 Pod as HTML

## Install

This module is in the [Perl 6 ecosystem](https://modules.perl6.org), so you install it in the usual way:

    zef install Pod::To::HTML

**Note**: Perl 6 2018.06 introduces changes on how non-breaking
  whitespace was handled; this is now included in the tests. If
  the installation fails, please upgrade to Perl 6 >= 2018.06 or
  simply disregard the test and install with `--force` if that
  particular feature is of no use to you.

## SYNOPSIS

From the command line:

    perl6 --doc=HTML lib/FancyModule.pm > FancyModule.html

From within Perl 6:

```perl6
# Pod Block
=pod My I<super B<awesome>> embedded C<pod> document!

say Pod::To::HTML.render($=pod[0]);

# Pod file
say Pod::To::HTML.render('your/file.pod'.IO, header =>
                         "your-custom-header-inside-body", footer =>
                         "your-custom-footer-inside-body", head-fields
                         => "tags-inside-head", lang => "document
                         language (defaults to 'en')", default-title =
                         'No =title was found so we use this', css-url
                         => 'https://example.com/css.css'); # specify
                         css-url as empty string to disable CSS
                         inclusion

# Pod string

my $pod = q:to/END/;
=pod
My I<super B<awesome>> embedded C<pod>
document!
END
say Pod::To::HTML.render($pod,
    header =>"your-custom-header-inside-body",
    footer => "your-custom-footer-inside-body",
	head-fields => "tags-inside-head",
    lang => "document language (defaults to 'en')",
	default-title => 'No =title was found so we use this');

```

## DESCRIPTION

`Pod::To::HTML` takes a Pod 6 tree and outputs correspondingly
formatted HTML. Generally this is done via the command line,
using`perl6 --doc=HTML`, which extracts the pod from the document and
feeds it to `Pod::To::HTML`. The other route is with the `render`
method (called by `--doc=HTML`), which creates a complete HTML
document from the Pod tree it is called with.

Optionally, a custom header/fooder/head-fields can be
provided. These can be used to link to custom CSS stylesheets and
JavaScript libraries.


## DEBUGGING

You can set the `P6DOC_DEBUG` environmental variable to make the
module produce some debugging information. 


## LICENSE

You can use and distribute this module under the terms of the The Artistic License 2.0. See the LICENSE file included in this distribution for complete details.

The META6.json file of this distribution may be distributed and modified without restrictions or attribution.

