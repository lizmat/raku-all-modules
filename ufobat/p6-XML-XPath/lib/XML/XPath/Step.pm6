use v6.c;
use XML::XPath::NodeTest;
use XML::XPath::Evaluable;
use XML::XPath::Predicates;
use XML::XPath::Types;
use XML::XPath::Utils;

class XML::XPath::Step does XML::XPath::Evaluable is XML::XPath::NodeTest {
    has Axis $.axis is rw is required;
    has XML::XPath::Step $.next is rw;
    has XML::XPath::Predicates $.predicates is rw = XML::XPath::Predicates.new;
    has Bool $.is-absolute is rw = False;

    method add-next(XML::XPath::Step $step) {
        if $.next {
            $.next.add-next($step);
        } else {
            $.next = $step;
        }
    }

    method evaluate(ResultType $set, Int $index, Int $of) {
        my $start-evaluation = $.is-absolute
        ?? self!get-resultlist-with-root($set)
        !! $set;

        my $result = self.evaluate-node($start-evaluation, $.axis);
        $result = $.predicates.evaluate-predicates($result);

        if $.next {
            my $next-step-result = [];
            for $result.kv -> $index, $node {
                $next-step-result.append: $.next.evaluate($node, $index, $result.elems).flat;
            }
            $result = $next-step-result;
        }
        return $result;
    }

    method !get-resultlist-with-root($elem) {
        return $elem ~~ XML::Document ?? $elem !! $elem.ownerDocument;
    }
}
