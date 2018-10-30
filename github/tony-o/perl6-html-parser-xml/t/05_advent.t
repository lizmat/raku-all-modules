use v6;
 
use lib 'lib';
use HTML::Parser::XML;
use Test;
plan 1;

# ab5tract++ timotimo++

my $html   = slurp 't/data/advent.html'; 
my $parser = HTML::Parser::XML.new;
$parser.parse( $html );

is $parser.xmldoc.root.elements[1].name, 'body', 'parse past self closing tags />';

# not sure what element paths to get to the unicode characters yet :/
# is $parser.xmldoc.root.elements[1].name, 'body', 'parse html with unicode';
