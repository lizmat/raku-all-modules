use v6;
use Test;

plan 1;

use XML;
use XML::Signature;

my $xml = from-xml(slurp "t/basic.xml");
$xml.root.idattr = 'Id';
ok verify($xml.root), 'Can verify valid signature';
