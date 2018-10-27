use v6;

use Test;
use Hinges;

my @valid-xml =
    '<a/>',
#    '<html />',           # todo
#    '<html></html>',      # todo
;

my @invalid-xml =
#    '',                   # todo
    '<',
    '<a',
    '<a>',
    '<a><b></a></b>',
;

sub parse($text) {
    my $succeeded = False;
    try {
        Hinges::XMLParser.new($text).llist();
        $succeeded = True;
    }
    $succeeded;
}

plan @valid-xml + @invalid-xml;

ok  parse($_), "$_ is valid"   for @valid-xml;
nok parse($_), "$_ is invalid" for @invalid-xml;
