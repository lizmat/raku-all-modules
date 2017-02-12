use v6.c;

use XML::XPath::InfixExprOperatorPerElement;

class XML::XPath::ExprOperator::SmallerThan does XML::XPath::InfixExprOperatorPerElement {

    method check($a, $b) {
        unless $a.defined and $b.defined {
            return False;
        }
        return $a < $b;
    }
}
