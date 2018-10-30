use v6.c;

use XML::XPath::Types;

class XML::XPath::ExprOperator::Pipe {
    method invoke($expr, ResultType $set, Int $index, Int $of) {
        my $first-set = $expr.operand.evaluate($set, $index, $of);
        my $other-set = $expr.other-operand.evaluate($set, $index, $of);
        $first-set.append($other-set.flat);
        return $first-set;
    }
}
