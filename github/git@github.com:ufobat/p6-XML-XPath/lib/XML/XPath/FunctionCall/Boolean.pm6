use v6.c;

use XML;
use XML::XPath::Types;
use XML::XPath::Utils;

role XML::XPath::FunctionCall::Boolean {

    method !fn-not(ResultType $set, Int $index, Int $of) {
        die 'functioncall not() requires one parameter' unless @.args.elems == 1;
        my $expression = @.args[0];
        my $interim = $expression.evaluate($set, $index, $of);
        return [ !$interim.Bool ];
    }

    method !fn-lang(ResultType $set, Int $index, Int $of) {
        die 'functioncall lang() requires one parameter' unless @.args.elems == 1;
        my $expression = @.args[0];
        my $interim    = $expression.evaluate($set, $index, $of);
        my $string     = unwrap($interim);
        my $xml-node   = $set;
        while $xml-node ~~ XML::Element {
            for $xml-node.attribs.kv -> $key, $val {
                if $key eq 'xml:lang' {
                    return [ $val.fc eq $string.fc ];
                }
            }
            $xml-node = $xml-node.parent;
        }
        return [ False ];
    }

}
