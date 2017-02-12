use v6.c;

use XML;
use XML::XPath::Types;

role XML::XPath::Evaluable {
    method evaluate(ResultType $point, Int $index, Int $of) { ... }
}
