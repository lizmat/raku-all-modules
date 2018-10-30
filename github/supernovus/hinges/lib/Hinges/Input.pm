use v6;

use Hinges::Stream;
use Hinges::XMLParser;

class ParseError {
}

sub XML($text) {
    return Hinges::Stream.new(@(Hinges::XMLParser.new($text)));
}
