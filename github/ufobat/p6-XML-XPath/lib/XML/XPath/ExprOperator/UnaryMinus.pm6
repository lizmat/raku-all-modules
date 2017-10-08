use v6.c;

use XML::XPath::Types;

class XML::XPath::ExprOperator::UnaryMinus {
    method invoke($expr, ResultType $set, Int $index, Int $of) {
        my $result = $expr.operand.evaluate($set, $index, $of);
        return [ $result.map: -* ];
    }
}
