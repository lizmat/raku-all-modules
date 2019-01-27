use XML;
use XML::XPath::Actions;
use XML::XPath::Grammar;
use XML::XPath::Utils;

class XML::XPath:ver<0.9.2> {
    has $.document;
    has %.registered-namespaces is rw;

    submethod BUILD(:$file, :$xml, :$document) {
        my $doc;
        if $document {
            $doc = $document;
        }
        elsif $file {
            die "file $file is not readable" unless $file.IO.r;
            $doc = from-xml-file($file);
        }
        elsif $xml {
            $doc = from-xml($xml);
        }
        $!document = $doc;
    }

    method find(Str $xpath, XML::Node :$start, Bool :$to-list) {
        my %*NAMESPACES  = %.registered-namespaces;
        my $parsed-xpath = self.parse-xpath($xpath);
        my $start-point  = $start ?? $start !! $.document;
        my $result       = $parsed-xpath.evaluate($start-point, 0, 1);
        unless $to-list {
            return unwrap $result, :to-nil(True);
        }
        return $result.flat;
    }

    method parse-xpath(Str $xpath) {
        my $actions        = XML::XPath::Actions.new();
        my $match          = XML::XPath::Grammar.parse($xpath, :$actions);
        my $parsed-xpath   = $match.ast;
        return $parsed-xpath;
    }

    method set-namespace(Pair $ns) {
        %.registered-namespaces{ $ns.key } = $ns.value;
    }

    method clear-namespaces {
        %.registered-namespaces = ();
    }
}
