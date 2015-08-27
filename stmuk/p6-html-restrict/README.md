HTML::Restrict
==============

WORK IN PROGRESS

Delete specified HTML tags, attributes and attribute values from HTML in an
attempt to sanitise HTML for safer use.

Heavily influenced by existing similar perl5 modules such as the one of the
same name.

CAUTION THIS MAY NOT BE SECURE FOR PRODUCTION USE YET.

Pull requests welcome.

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

Defaults for @.good-tags, $.recurse-depth and @.bad-attrib-vals are as above so
may be omitted.

-- steve.mynott@gmail.com 20150806

# p6-html-restrict
