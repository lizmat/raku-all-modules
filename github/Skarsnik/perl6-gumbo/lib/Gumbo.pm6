# This project is under the same licence as Rakudo
use v6;

=begin pod

=head1 Name Gumbo

=head1 Synopsis

  use Gumbo;
  use LWP::Simple;
  
  my $xml = parse-html(LWP::Simple.get("www.google.com"));
  say $xml.lookfor(:TAG<title>); # Google;

=head1 Description

From the Gumbo project page :

Gumbo is an implementation of the HTML5 parsing algorithm implemented as a pure C99 library with no outside dependencies.
It's designed to serve as a building block for other tools and libraries such as linters, validators, templating languages, and refactoring and analysis tools.


This module is a binding to this library. It provide a C<parse-html> routine that parse a given html string and return a C<XML::Document> object.
To access all the Gumbo library has to offer you probably want to look at the C<Gumbo::Binding> module.

=head1 Usage

=head2 parse-html(Str $html) : XML::Document 

Parse a html string and retrurn a C<XML::Document>. 

=head2 parse-html(Str $html, :$nowhitespace, *%filters) : XML::Document

This is the full signature of the C<parse-html> routine.

=item1 nowhitespace

Tell Gumbo to not include all extra whitespaces that can exist around tag, like intendation put in front of html tags

=item1 *%filters

The module offer some form of basic filtering if you want to restrict the C<XML::Document> returned. 
You can only filter on elements (understand tags) and not content like the text of a C<<p>> tag.

It inspired by the C<elements> method of the C<XML::Element> class. The main purpore is to reduce time spent
parsing uneccessary content and decrease the memory print of the C<XML::Document>.

IMPORTANT: the root will always be the html tag.

=item2 TAG
    Limits to elements with the given tag name

=item2 SINGLE
    If set only get the first match

=item2 attrib
    You can filter on one attribute name with his given value

All the children of the element(s) matched are kept. Like if you search for all the links,
you will get the eventuals additionals tags put around the text part.

=head2 $gumbo_last_c_parse_duration && $gumbo_last_xml_creation_duration

These two variables hold the time (C<Duration>) spend in the two steps of the work parse-html does.
    
=head1 Example

 use Gumbo;

 my $html = q:to/END_HTML/;
 <html>
 <head>
        <title>Fancy</title>
 </head>
 <body>
        <p>It's fancy</p>
        <p class="fancier">It's fancier</p>
 </body>
 </html>

 END_HTML

 my $xmldoc = parse-html($html);

 say $xmldoc.root.elements(:TAG<p>, :RECURSE)[0][0].text; #It's fancy

 $xmldoc = parse-html($html, :TAG<p>, :SINGLE);

 say $xmldoc[0][0].text; #It's still fancy

 $xmldoc = parse-html($html, :TAG<p>, :class<fancier>, :SINGLE);

 say $xmldoc[0][0].text; # It's fancier

=head1 Gumbo::Parser

This module provide a Gumbo::Parser class that does the role defined by the C<HTML::Parser> module.
It also provide some additionnals attributes that contains various informations. It work exactly
like the C<parse-html> method with the same extra optionnals arguments.

  use Gumbo::Parser;

  my $parser = Gumbo::Parser.new;
  my $xmldoc = $parser->parse($html);
  say $parser.c-parse-duration;
  say $parser.xml-creation-duration;
  say $parser.stats<xml-objects>; # the number of XML::* created (excluding the XML::Document)
  say $parser.stats<whitespaces>; # the number of Whitespaces elements (created or not)
  say $parser.stats<elements>; # the number of XML::Element (including root)

  
=head1 See Also

C<XML>, C<HTML::Parser::XML>

=head1 Copyright

Sylvain "Skarsnik" Colinet <scolinet@gmail.com>

=head1 License

The modules provided by Gumbo are under the same licence as Rakudo
=end pod

use XML;
use Gumbo::Parser;

module Gumbo {

  our $gumbo_last_c_parse_duration is export;
  our $gumbo_last_xml_creation_duration is export;

  sub parse-html (Str $html, :$nowhitespace = False, *%filters) is export {
    my $parser = Gumbo::Parser.new;
    my $xmldoc = $parser.parse($html, :nowhitespace($nowhitespace), |%filters);
    $gumbo_last_c_parse_duration = $parser.c-parse-duration;
    $gumbo_last_xml_creation_duration = $parser.xml-creation-duration;
    return $xmldoc;
  }

}
