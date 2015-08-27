use v6;
use HTML::Parser::XML;

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
