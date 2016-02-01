use v6;
use HTML::Parser::XML;

=begin pod

=head1 NAME

HTML::Restrict - attempt to sanitise HTML via good and bad tags

=head1 SYNOPSIS

=begin code

   use HTML::Restrict;

   my $hr = HTML::Restrict.new(
                      :good-tags(<a b br em hr i img p strong tt u>),
                      :bad-attrib-vals(any(rx/onmouseover/, rx/javascript/)),
                      :recurse-depth(100), 
                      );

   my XML::Document $doc = $hr.process(:$html);

   my $got = $doc.gist;

=end code

=head1 DESCRIPTION

CAUTION THIS MAY NOT BE SECURE FOR PRODUCTION USE YET.

Delete specified HTML tags, attributes and attribute values from HTML in an
attempt to sanitise HTML for safer use.

Heavily influenced by existing similar perl5 modules such as the one of the
same name.

Defaults for @.good-tags, $.recurse-depth and @.bad-attrib-vals are as above so
may be omitted.

Pull requests welcome.

=head1 AUTHOR

Steve Mynott <steve.mynott@gmail.com> 20150806

=end pod

class HTML::Restrict {

    has @.good-tags =  <a b br em hr i img p strong tt u>;
    has @.bad-attrib-vals = any(rx/onmouseover/, rx/javascript/);
    has $.recurse-depth = 100;

    my $recurse-count = 0;

    method process(:$html is copy) {

        # strip out PHP
        $html ~~ s:g/'<?php' .*? '?>'//;

        my $parser = HTML::Parser::XML.new;
        my XML::Document $doc = $parser.parse($html);

        self.walk($doc);

        $recurse-count = 0;

        return $doc
    }

    method walk($doc) {
        for $doc.elements -> $elem {

            if $elem.nodes {
                self.walk-nodes($elem.nodes);
            }

            self.clean($elem) ; # XXX
        }
    }

    method walk-nodes(@nodes) {

        # this is recusive and needs a limit XXX
        $recurse-count++;
        #die "recurse count reached" if $recurse-count == $.recurse-depth;

        for @nodes -> $elem {
            next if $elem.can('text'); # work around .WHAT issue XXX
            self.clean($elem) ;

            if $elem.can('nodes') and  $elem.nodes {
                self.walk-nodes($elem.nodes);
            }

        }

    }

    method clean($elem) {

        if $elem.can('name') {
            unless $elem.name eq any @.good-tags {
                my $child = $elem.nextSibling();

                $elem.removeChild($child) if $child.so;

            }
        }

        if $elem.can('attribs') and $elem.attribs.values.so {
            for $elem.attribs.kv -> $k, $v {
                if $k.lc ~~ any @.bad-attrib-vals or $v.lc ~~ any @.bad-attrib-vals {
                    $elem.unset($k);
                }

            }
        }

    }
}
