NAME
====

HTML::Restrict - attempt to sanitise HTML via good and bad tags

SYNOPSIS
========

       use HTML::Restrict;

       my $hr = HTML::Restrict.new(
                          :good-tags(<a b br em hr i img p strong tt u>),
                          :bad-attrib-vals(any(rx/onmouseover/, rx/javascript/)),
                          :recurse-depth(100), 
                          );

       my XML::Document $doc = $hr.process(:$html);

       my $got = $doc.gist;

DESCRIPTION
===========

CAUTION THIS MAY NOT BE SECURE FOR PRODUCTION USE YET.

Delete specified HTML tags, attributes and attribute values from HTML in an attempt to sanitise HTML for safer use.

Heavily influenced by existing similar perl5 modules such as the one of the same name.

Defaults for @.good-tags, $.recurse-depth and @.bad-attrib-vals are as above so may be omitted.

Pull requests welcome.

AUTHOR
======

Steve Mynott <steve.mynott@gmail.com> 20150806
