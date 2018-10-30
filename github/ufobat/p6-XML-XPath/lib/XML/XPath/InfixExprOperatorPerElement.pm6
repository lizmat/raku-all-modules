use v6.c;

use XML::XPath::Types;
use XML::XPath::Utils;
use XML;

role XML::XPath::InfixExprOperatorPerElement {
    method check($a, $b) { ... }

    method invoke($expr, ResultType $set, Int $index, Int $of) {
        my $first-set = $expr.operand.evaluate($set, $index, $of);
        my $other-set = $expr.other-operand.evaluate($set, $index, $of);

#        say "invoke: ", $first-set.perl, $other-set.perl;
        return self.op-result-helper(unwrap($first-set), unwrap($other-set));
    }

    multi method op-result-helper(ResultType $one, ResultType $another) {
        return [ self.check($one, $another) ];
    }

    multi method op-result-helper(Array $one, ResultType $another) {
        my $result = [];
        for $one.values -> $node {
            $result.push: self.check($node, $another);
        }
        return $result;
    }

    multi method op-result-helper(ResultType $one, Array $another) {
        my $result = [];
        for $another.values -> $node {
            #            $result.add: self.op-result-helper($node, $one);
            $result.push: self.check($one, $node);
        }
        return $result;
    }

    multi method op-result-helper(Array $one, Array $another) {
        my $maxsize = $one.elems max $another.elems;
        my $result  = [];
        for 0..$maxsize -> $index {
#            say "index $index -> ", $one[$index], " - ", $another[$index];
            $result.append: self.op-result-helper($one[$index], $another[$index]).flat
        }
        return $result;
    }
}
