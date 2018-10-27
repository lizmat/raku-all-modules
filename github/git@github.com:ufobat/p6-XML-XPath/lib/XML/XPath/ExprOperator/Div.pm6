use v6.c;

use XML::XPath::InfixExprOperatorPerElement;

class XML::XPath::ExprOperator::Div does XML::XPath::InfixExprOperatorPerElement {

    method check($a, $b) {
        unless $a.defined and $b.defined {
            return False;
        }
        my $val_a = $a ~~ XML::Node ?? self!node-to-value($a) !! $a;
        my $val_b = $b ~~ XML::Node ?? self!node-to-value($b) !! $b;
        my $value;

        if $val_a == 0 and $val_b == 0 {
            $value = NaN;
        } elsif $val_b == 0 {
            $value = $val_a * Inf;
        } else {
            $value = $val_a / $val_b;
        }
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
