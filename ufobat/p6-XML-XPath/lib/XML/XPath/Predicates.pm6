use v6.c;

use XML::XPath::Utils;

class XML::XPath::Predicates {
    has @.predicates;

    method evaluate-predicates(Array $start is copy) {
        for @.predicates -> $predicate {
            my $interim = [];
            for $start.kv -> $index, $node {
                say "\npredicate $index";
                my $predicate-result = $predicate.evaluate($node, $index, $start.elems);
                #say $node.perl;
                say $predicate-result.perl;

                $predicate-result = unwrap($predicate-result);

                if $predicate-result ~~ Numeric and $predicate-result !~~ Stringy and $predicate-result !~~ Bool {
                    $interim.push: $node if $predicate-result - 1 == $index;
                } elsif $predicate-result ~~ Bool {
                    $interim.push: $node if $predicate-result.Bool;
                } elsif $predicate-result ~~ Str {
                    $interim.push: $node if $predicate-result.Bool;
                } else {
                    for $predicate-result.kv -> $i, $node-result {
                        $interim.push: $start[$i] if $node-result.Bool;
                    }
                }
            }
            $start = $interim;
        }

        return $start;
    }
}
