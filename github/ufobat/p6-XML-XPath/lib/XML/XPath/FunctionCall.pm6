use v6.c;

use XML::XPath::Evaluable;
use XML::XPath::Types;
use XML::XPath::Utils;
use XML::XPath::FunctionCall::String;
use XML::XPath::FunctionCall::Boolean;
use XML::XPath::FunctionCall::Number;
use XML::XPath::FunctionCall::Node;

class XML::XPath::FunctionCall
does XML::XPath::Evaluable
does XML::XPath::FunctionCall::String
does XML::XPath::FunctionCall::Boolean
does XML::XPath::FunctionCall::Node
does XML::XPath::FunctionCall::Number
{
    has $.function is required;
    has @.args;

    method evaluate(ResultType $set, Int $index, Int $of) {
        return self!"fn-{ $.function }"($set, $index, $of);
    }

    method !help-one-arg(ResultType $set, Int $index, Int $of, Sub $converter) {
        my $expr    = @.args[0];
        my $interim = $expr.evaluate($set, $index, $of);
        if $interim ~~ Array {
            my $result = [];
            for $interim.values -> $node {
                $result.push: $converter.($node);
            }
            return $result;
        }
    }

    method !help-two-arg-second-string(ResultType $set, Int $index, Int $of, Sub $converter) {
        my $interim        = @.args[0].evaluate($set, $index, $of);
        my $string-result  = @.args[1].evaluate($set, $index, $of);
        my $string = unwrap($string-result);
        unless $string ~~ Str {
            die 'functioncall 2nd expression must evaluate into a String';
        }
        if $interim ~~ Array {
            my $result  = [];
            for $interim.values -> $node {
                $result.push: $converter.($node, $string);
            }
            return $result;
        } else {
            return [ $converter.($interim, $string) ];
        }
    }

    method !help-three-arg-second-thrid-string(ResultType $set, Int $index, Int $of, Sub $converter) {
        my $interim        = @.args[0].evaluate($set, $index, $of);
        my $string-result1 = @.args[1].evaluate($set, $index, $of);
        my $string-result2 = @.args[2].evaluate($set, $index, $of);
        my $string1        = unwrap($string-result1);
        my $string2        = unwrap($string-result2);
        unless $string1 ~~ Str or $string2 ~~ Str {
            die 'functioncall 2nd and 3rd expression must evaluate into a String';
        }
        if $interim ~~ Array {
            my $result  = [];
            for $interim.values -> $node {
                $result.push: $converter.($node, $string1, $string2);
            }
            return $result;
        } else {
            return [ $converter.($interim, $string1, $string2) ];
        }
    }
}
