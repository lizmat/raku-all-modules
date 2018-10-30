use v6.c;

use XML::XPath::InfixExprOperatorPerElement;

class XML::XPath::ExprOperator::And does XML::XPath::InfixExprOperatorPerElement {

    method check($a, $b) {
        unless $a.defined and $b.defined {
            return False;
        }
        my $val_a = $a ~~ XML::Node ?? self!node-to-value($a) !! $a;
        my $val_b = $b ~~ XML::Node ?? self!node-to-value($b) !! $b;
        my $value = $val_a.Bool && $val_b.Bool;
        return $value;
    }

    method !node-to-value(XML::Node $node) {
        if $node ~~ XML::Element {
            my $txt = $node.contents.join: '';
            return $txt;
        } else {
            X::NYI.new(feature => 'can not handle non XML::Element nodes').throw;
        }
    }
}
