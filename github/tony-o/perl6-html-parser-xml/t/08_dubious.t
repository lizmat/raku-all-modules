use lib 'lib';
use HTML::Parser::XML;
use Test;

my $parser = HTML::Parser::XML.new;

my $data = slurp 't/data/dubious.html';

$parser.parse($data);

my $xmldoc = $parser.xmldoc;

plan 5;

my $divpony = $xmldoc.root.elements(:TAG<div>, :class<ponies>, :RECURSE<3>)[0];

#say "div pony" , $(@divpony);

ok $divpony.elements.elems eq 3, "Found the 3 elements in the ponies div";

ok $divpony.elements(:TAG<img>, :class<unicorn>, :RECURSE<5>, :SINGLE), "Found the unicorn image";
ok $divpony.elements(:TAG<img>, :class<pegasus>, :RECURSE<5>, :SINGLE), "Found the pegasus image";

my $unicorn_img = $divpony.elements(:TAG<img>, :class<unicorn>, :RECURSE<5>)[0];
my $pegasus_img = $divpony.elements(:TAG<img>, :class<pegasus>, :RECURSE<5>)[0];

ok $unicorn_img.attribs<src> eq 'unicorn.png', "Right value for unicorn image";
ok $pegasus_img.attribs<src> eq 'pegasus.png', "Right value for pegasus image";
