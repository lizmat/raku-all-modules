# This project is under the same licence as Rakudo
use v6;

use XML;

use Gumbo::Parser;

module Gumbo {

  our $gumbo_last_c_parse_duration is export;
  our $gumbo_last_xml_creation_duration is export;

  sub parse-html (Str $html, :$nowhitespace = False, *%filters) is export {
    my $parser = Gumbo::Parser.new;
    my $xmldoc = $parser.parse($html, :nowhitespace($nowhitespace), |%filters);
    $gumbo_last_c_parse_duration = $parser.c_parse_duration;
    $gumbo_last_xml_creation_duration = $parser.xml_creation_duration;
    return $xmldoc;
  }

}
